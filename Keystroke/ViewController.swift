//
//  ViewController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import ReSwift
import PureLayout

let KEY_SIZE = NSSize(width: 50.0, height: 50.0)
let CONTAINER_VIEW_INSETS = EdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
let KEY_FONT_SIZE: CGFloat = 20.0
let KEY_SPACING: CGFloat = 10.0
let KEY_TEXT_PADDING: CGFloat = 20.0
let KEY_BORDER_COLOR = NSColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)

class ViewController: NSViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    @IBOutlet var keyboardView: NSView!
    
    let bindingLoader = BindingLoader()
    private var rowViews: [NSView] = []
    private var keyViews: [[NSView]] = [[], [], []]
    private var keyViewsWidths: [CGFloat] = [0.0, 0.0, 0.0]
    private var keyFont: NSFont? = nil
    private var containerView: NSView? = nil
    
    var keyRows: [[KeyboardKey]] = []
    
    private func configureKeyRows() {
        if keyRows.count > 0 {
            keyRows.removeAll()
        }
        
        keyRows = [
            [KeyCode.Key_q,
             KeyCode.Key_w,
             KeyCode.Key_e,
             KeyCode.Key_r,
             KeyCode.Key_t,
             KeyCode.Key_y,
             KeyCode.Key_u,
             KeyCode.Key_i,
             KeyCode.Key_o,
             KeyCode.Key_p].map({ keyCode in
                mainStore.state.keyboard.keys[keyCode]!
             }),
            [KeyCode.Key_a,
             KeyCode.Key_s,
             KeyCode.Key_d,
             KeyCode.Key_f,
             KeyCode.Key_g,
             KeyCode.Key_h,
             KeyCode.Key_j,
             KeyCode.Key_k,
             KeyCode.Key_l].map({ keyCode in
                mainStore.state.keyboard.keys[keyCode]!
             }),
            [KeyCode.Key_z,
             KeyCode.Key_x,
             KeyCode.Key_c,
             KeyCode.Key_v,
             KeyCode.Key_b,
             KeyCode.Key_n,
             KeyCode.Key_m].map({ keyCode in
                mainStore.state.keyboard.keys[keyCode]!
             })
        ]

    }
    
    private func configureKeyboardView() {
        // Setup flow layout
        
        if rowViews.count > 0 {
            rowViews.removeAll()
            keyViews.removeAll()
            keyViews = [[], [], []]
            keyViewsWidths = [0.0, 0.0, 0.0]
        }
        
        if keyFont == nil {
            keyFont = NSFont(name: "San Francisco Display Light", size: KEY_FONT_SIZE)
        }
        
        if self.containerView != nil {
            self.containerView!.removeFromSuperview()
        }
        
        self.containerView = NSView.newAutoLayout()
        
        let container = self.containerView!
        
        view.addSubview(container)
        container.autoAlignAxis(.vertical, toSameAxisOf: view)
        container.autoPinEdgesToSuperviewEdges(with: CONTAINER_VIEW_INSETS)
        
        for (rowIndex, row) in keyRows.enumerated() {
            let rowView = NSView.newAutoLayout()
            rowViews.append(rowView)
            container.addSubview(rowView)
            rowView.autoPinEdge(toSuperviewEdge: .left)
            rowView.autoPinEdge(toSuperviewEdge: .right)
            rowView.autoSetDimension(.height, toSize: KEY_SIZE.height)
            rowView.wantsLayer = true
            if rowIndex < 1 {
                rowView.autoPinEdge(toSuperviewEdge: .top)
            } else {
                rowView.autoPinEdge(.top, to: .bottom, of: rowViews[rowIndex - 1], withOffset: KEY_SPACING)
            }
            
            // Clean views array
            if keyViews[rowIndex].count > 0 {
                keyViews[rowIndex].removeAll()
            }
            
            for (keyIndex, key) in row.enumerated() {
                let keyView = KeyView.create()
                keyView.stringValue = key.title
                
                keyView.font = keyFont!
                keyViews[rowIndex].append(keyView)
                rowView.addSubview(keyView)
                
                let textSize = calculateSize(of: keyView.stringValue, using: keyFont!)
                let keyWidthWithPadding = max(textSize.width + KEY_TEXT_PADDING, KEY_SIZE.width)
                
                keyViewsWidths[rowIndex] = keyViewsWidths[rowIndex] + keyWidthWithPadding
                
                keyView.autoSetDimensions(to: CGSize(
                    width: keyWidthWithPadding,
                    height: KEY_SIZE.height
                ))
                
                if keyIndex >= 1, keyIndex < keyRows[rowIndex].count {
                    keyView.autoPinEdge(.left, to: .right, of: keyViews[rowIndex][keyIndex - 1], withOffset: KEY_SPACING)
                }
            }
            
            let rowWidth = keyViewsWidths[rowIndex] + (CGFloat(keyViews[rowIndex].count - 1) * KEY_SPACING)
            let firstKeyViewInRow = keyViews[rowIndex][0]
            
            firstKeyViewInRow.autoPinEdge(
                toSuperviewEdge: .left,
                withInset: (WINDOW_SIZE.width - CONTAINER_VIEW_INSETS.left - CONTAINER_VIEW_INSETS.right - rowWidth) / 2
            )
        }
    }
    
    func activateTheme(theme: Theme) {
        guard let layer = view.layer else { return }
        layer.backgroundColor = NSColor.init(
            calibratedRed: theme.backgroundColor.calibratedRed,
            green: theme.backgroundColor.green,
            blue: theme.backgroundColor.blue,
            alpha: theme.backgroundColor.alpha
            ).cgColor;
    }
    
    func newState(state: AppState) {
        // self.loadDataForAppWithName(state.view.appName)
        self.activateTheme(theme: state.theme.theme)
        
        configureKeyRows()
        configureKeyboardView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainStore.subscribe(self)
        
        configureKeyRows()
        configureKeyboardView()
        startKeyListener()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.gray.cgColor
        view.layer?.cornerRadius = 10
    }
    
    func startKeyListener() {
        func callback(
            proxy: OpaquePointer,
            type: CGEventType,
            event: CGEvent,
            refcon: UnsafeMutableRawPointer?
            ) -> Unmanaged<CGEvent>? {
            
            handleKeyEvent(type: type, event: event)
            
            // Check event to popagate
            guard let newEvent = mainStore.state.keyboard.lastEvent else { return nil }
            // Hide main window
            mainStore.dispatch(WindowHideAction())
            
            return Unmanaged.passRetained(newEvent)
        }
        
        let eventMask =
            (1 << CGEventType.keyDown.rawValue)
                | (1 << CGEventType.keyUp.rawValue)
                | (1 << CGEventType.flagsChanged.rawValue)
                | (1 << CGEventType.leftMouseDown.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: nil) else {
                print("failed to create event tap")
                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        //CFRunLoopRun()
    }
    
    func loadDataForAppWithName(_ appName: String?) {
        bindingLoader.loadDataForAppWithName(appName ?? "")
        // collectionView.reloadData()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension ViewController : NSCollectionViewDataSource {
    
    // Can be omitted for single section
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return bindingLoader.numberOfSections
    }
    
    // This is one of two required methods for NSCollectionViewDataSource.
    // Here you return the number of items in the section specified by the section parameter.
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return bindingLoader.numberOfItems(in: section)
    }
    
    // This is the second required method. It returns a collection view item for a given indexPath.
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else {return item}
        
        let action = bindingLoader.bindingForIndexPath(indexPath)
        
        collectionViewItem.actionText = "\(action.descriptionText)"
        return item
    }
    
}
