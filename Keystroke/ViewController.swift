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

class ViewController: NSViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    @IBOutlet var keyboardView: NSView!
    
    let bindingLoader = BindingLoader()
    var rowViews: [NSView] = []
    var keyViews: [[NSView]] = [[], [], []]
    let keyFont = NSFont(name: "San Francisco Display Light", size: 20.0)
    
    var keyRows: [[KeyboardKey]] = [
        "qwertyuiop".characters.map({ char in
            mainStore.state.keyboard.keys[String(char)]!
        }),
        "asdfghjkl".characters.map({ char in
            mainStore.state.keyboard.keys[String(char)]!
        }),
        "zxcvbnm".characters.map({ char in
            mainStore.state.keyboard.keys[String(char)]!
        })
    ]
    
    private func configureKeyboardView() {
        // Setup flow layout
        
        if rowViews.count > 0 {
            rowViews.removeAll()
        }
        
        //        if keyViews.count > 0 {
        //            keyViews.removeAll()
        //        }
        
        let containerView = NSView.newAutoLayout()
        view.addSubview(containerView)
        containerView.autoAlignAxis(.vertical, toSameAxisOf: view)
        containerView.autoPinEdgesToSuperviewEdges(with: EdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        
        for (rowIndex, row) in keyRows.enumerated() {
            let rowView = NSView.newAutoLayout()
            rowViews.append(rowView)
            containerView.addSubview(rowView)
            rowView.autoSetDimensions(to: CGSize(width: 800.0, height: 50.0))
            rowView.wantsLayer = true
            rowView.layer?.borderWidth = 2
            rowView.layer?.borderColor = NSColor.red.cgColor
            if rowIndex < 1 {
                rowView.autoPinEdge(toSuperviewEdge: .top)
            } else {
                rowView.autoPinEdge(.top, to: .bottom, of: rowViews[rowIndex - 1], withOffset: 10.0)
                //rowView.autoPinEdge(.top, to: .bottom, of: rowViews[rowIndex - 1])
            }
            
            for (keyIndex, key) in row.enumerated() {
                let keyView = NSTextField.newAutoLayout()
                keyView.stringValue = key.title.uppercased()
                keyView.font = keyFont!
                keyViews[rowIndex].append(keyView)
                rowView.addSubview(keyView)
                keyView.wantsLayer = true
                keyView.alignment = .center
                
                let textSize = calculateSize(of: keyView.stringValue, using: keyFont!)
                print(textSize)
        
                keyView.layer?.borderWidth = 1.5
                keyView.layer?.borderColor = NSColor.green.cgColor
                keyView.layer?.cornerRadius = 4
                keyView.autoSetDimensions(to: CGSize(
                    width: max(textSize.width + 20.0, 50.0),
                    height: 50.0
                ))

                if keyIndex < 1 {
                    keyView.autoPinEdge(toSuperviewEdge: .left)
                } else {
                    keyView.autoPinEdge(.left, to: .right, of: keyViews[rowIndex][keyIndex - 1], withOffset: 10.0)
                }
            }
            
//            (keyViews[rowIndex] as NSArray).autoDistributeViews(along: .horizontal, alignedTo: .baseline, withFixedSpacing: 10.0)
            //(keyViews[rowIndex] as NSArray).autoDistributeViews(along: .horizontal, alignedTo: .horizontal, withFixedSize: 10.0)
            
            //(keyViews[rowIndex] as NSArray).autoDistributeViews(along: .horizontal, alignedTo: .horizontal, withFixedSize: 50.0)
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
        self.loadDataForAppWithName(state.view.appName)
        self.activateTheme(theme: state.theme.theme)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainStore.subscribe(self)
        
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
            
            //            let viewController: ViewController = transfer(ptr: refcon!)
            mainStore.dispatch(handleKeyEvent(type: type, event: event))
            
            return Unmanaged.passRetained(mainStore.state.view.lastEvent!)
        }
        
        let eventMask =
            (1 << CGEventType.keyDown.rawValue) |
                (1 << CGEventType.keyUp.rawValue) |
                (1 << CGEventType.flagsChanged.rawValue) |
                (1 << CGEventType.leftMouseDown.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: bridge(obj: self)) else {
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
