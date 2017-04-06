//
//  ViewController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

func bridge<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func transfer<T : AnyObject>(ptr : UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

class ViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    let actionLoader = ActionLoader()
    
    var windowVisible = true
    var skip = false

    private func configureCollectionView() {
        // Setup flow layout
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 40.0)
        flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout

        // For optimal performance, NSCollectionView is designed to be layer-backed.
        view.wantsLayer = true
        
        // Transparent background
        collectionView.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        actionLoader.loadDataForAppWithName("test")
        configureCollectionView()
        startKeyListener()
    }
    
    func startKeyListener() {
        func callback(
            proxy: OpaquePointer,
            type: CGEventType,
            event: CGEvent,
            refcon: UnsafeMutableRawPointer?
            ) -> Unmanaged<CGEvent>? {
            
            let viewController: ViewController = transfer(ptr: refcon!)
            
            func hideWindow() {
                viewController.view.window?.orderOut(true)
                viewController.windowVisible = false
            }
            
            func showWindow() {
                viewController.view.window?.orderFront(true)
                viewController.windowVisible = true
            }
            
            //  if [.keyDown , .keyUp].contains(type) {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            let hasCommand = flags.contains(CGEventFlags.maskCommand)
            print(keyCode.description, hasCommand)
            let appName = NSWorkspace.shared().frontmostApplication?.localizedName
            
            
            viewController.loadDataForAppWithName(appName!)
            
            if keyCode == 53 && viewController.windowVisible {
                // hide with escape
                viewController.view.window!.orderOut(true)
                viewController.windowVisible = false
            }
            
            if keyCode != 53 && keyCode != 55 && !viewController.windowVisible && hasCommand {
                // Skip on cmd+something (e.g cmd+tab)
                viewController.skip = true
                return Unmanaged.passRetained(event)
            }
            
            if (appName == "iTerm2") {
                if viewController.windowVisible && [.keyDown].contains(type) {
                    
                    if keyCode == 9 {
                        // replace mnemonic cmd - v with cmd+shift+d, split
                        event.setIntegerValueField(.keyboardEventKeycode, value: 2)
                        event.flags = event.flags.union(CGEventFlags.maskCommand)
                    } else if keyCode == 1 {
                        // replace mnemonic cmd - s with cmd+d, vetical split
                        event.setIntegerValueField(.keyboardEventKeycode, value: 2)
                        event.flags = event.flags.union(CGEventFlags.maskCommand)
                        event.flags = event.flags.union(CGEventFlags.maskShift)
                    }
                    
                    
                    hideWindow()
                    
                    return Unmanaged.passRetained(event)
                }
            }
            
            if keyCode == 55 {
                if viewController.windowVisible {
                    if !hasCommand {
                        viewController.view.window?.orderOut(true)
                        viewController.windowVisible = false
                    }
                } else {
                    if !hasCommand {
                        if !viewController.skip {
                            viewController.view.window?.orderFront(true)
                            viewController.windowVisible = true
                        } else {
                            viewController.skip = false
                        }
                    }
                }
            }
            
            //
            //}
            return Unmanaged.passRetained(event)
        }
        
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
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
    
    func loadDataForAppWithName(_ appName: String) {
        actionLoader.loadDataForAppWithName(appName)
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
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return actionLoader.numberOfSections
    }
    
    // This is one of two required methods for NSCollectionViewDataSource.
    // Here you return the number of items in the section specified by the section parameter.
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionLoader.numberOfItemsInSection(section)
    }
    
    // This is the second required method. It returns a collection view item for a given indexPath.
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else {return item}
        
        let action = actionLoader.actionItemForIndexPath(indexPath)

        collectionViewItem.actionText = "\(action.bindingKey) - \(action.descriptionText)"
        return item
    }
    
}
