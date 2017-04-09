//
//  WindowController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import ReSwift

class WindowController: NSWindowController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    func activateTheme(theme: Theme) {
        if let window = window {
            window.backgroundColor = NSColor.init(
                calibratedRed: theme.backgroundColor.calibratedRed,
                green: theme.backgroundColor.green,
                blue: theme.backgroundColor.blue,
                alpha: theme.backgroundColor.alpha
            );
        }
        
    }
    
    func newState(state: AppState) {
        activateTheme(theme: state.theme.theme)
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
            let quaterWidth = screenRect.width / 4.0
            let quaterHeight = screenRect.height / 4.0
            
            window.setFrame(
                NSRect(x: screenRect.origin.x + (quaterWidth / 2.0),
                       y: screenRect.origin.y - (quaterHeight * 3.0),
                       width: quaterWidth * 3.0,
                       height: quaterHeight
                ),
                display: true
            )
            
            // Set window floating on top
            window.level = Int(CGWindowLevelForKey(.maximumWindow))
            
            // A bad attemt to hide on startup
            //            window.orderOut(true)
            
            window.isMovableByWindowBackground  = true;
            
            // Make window transparent
//            window.isOpaque = false
            window.hasShadow = true
//            window.styleMask = .borderless
            
            activateTheme(theme: DarkTheme)
            
            
            // Try to move to active space, works for desktops
            // but doesnt work for fullscreen apps :(
            // see http://stackoverflow.com/questions/1740412/how-to-bring-nswindow-to-front-and-to-the-current-space
            NSApp.activate(ignoringOtherApps: true)
            window.collectionBehavior = .canJoinAllSpaces
        }
    }
}
