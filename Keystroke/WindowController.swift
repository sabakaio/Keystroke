//
//  WindowController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import ReSwift

let WINDOW_SIZE = NSSize(width: 1000.0, height: 190.0)
let WINDOW_PADDING_FROM_BOTTOM: CGFloat = 20.0

class WindowController: NSWindowController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
       
    func newState(state: AppState) {
        if (state.view.windowVisible) {
            showWindow()
        } else {
            hideWindow()
        }
    }
    
    func hideWindow() {
        window!.orderOut(true)
    }
    
    func showWindow() {
        window!.orderFront(true)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Check accessibility settings
        // see: http://stackoverflow.com/questions/36258866/how-to-access-accessibility-settings-in-macosx-cocoa-app-using-swift
        // see: http://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
        let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        print("Accessibility enabled: \(accessibilityEnabled)")
        
        mainStore.subscribe(self)
        
        // Position window
        if let window = window, let screen = NSScreen.main() {
            let screenRect = screen.visibleFrame
            
            window.setFrame(
                NSRect(x: screenRect.origin.x + ((screenRect.width - WINDOW_SIZE.width) / 2),
                       y: screenRect.origin.y + WINDOW_PADDING_FROM_BOTTOM,
                       width: WINDOW_SIZE.width,
                       height: WINDOW_SIZE.height
                ),
                display: true
            )
            
            window.minSize = NSSize(width: WINDOW_SIZE.width, height: WINDOW_SIZE.height)
            window.maxSize = NSSize(width: WINDOW_SIZE.width, height: WINDOW_SIZE.height)
            
            window.backgroundColor = NSColor.clear
            
            // Set window floating on top
            window.level = Int(CGWindowLevelForKey(.maximumWindow))
            
            window.isMovableByWindowBackground  = true;
            
            // Make window transparent
//            window.isOpaque = false
//            window.hasShadow = true
//            window.styleMask = .borderless
            
            
            // Try to move to active space, works for desktops
            // but doesnt work for fullscreen apps :(
            // see http://stackoverflow.com/questions/1740412/how-to-bring-nswindow-to-front-and-to-the-current-space
            NSApp.activate(ignoringOtherApps: true)
//            window.collectionBehavior = .canJoinAllSpaces
        }
    }
}
