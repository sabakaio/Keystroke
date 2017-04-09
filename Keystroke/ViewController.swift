//
//  ViewController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import ReSwift

class ViewController: NSViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    let bindingLoader = BindingLoader()
    
    private func configureCollectionView() {
        // Setup flow layout
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 50.0, height: 50.0)
        flowLayout.sectionInset = EdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        collectionView.collectionViewLayout = flowLayout
        
        // For optimal performance, NSCollectionView is designed to be layer-backed.
        collectionView.wantsLayer = true
        
        // Transparent background
        collectionView.layer?.backgroundColor = NSColor.clear.cgColor
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
        
        configureCollectionView()
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
        collectionView.reloadData()
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
