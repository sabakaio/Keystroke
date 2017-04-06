//
//  WindowController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
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
                )
                , display: true)
        }
        
        // Set window floating on top
        self.window!.level = Int(CGWindowLevelForKey(.maximumWindow))
        
        // A bad attemt to hide on startup
        self.window!.orderOut(true)
        
        // Hide title
        self.window!.titleVisibility = NSWindowTitleVisibility.hidden;
        self.window!.titlebarAppearsTransparent = true;
        self.window!.isMovableByWindowBackground  = true;
        
        // Hide top left buttons
        self.window!.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true;
        self.window!.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = true;
        self.window!.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = true;
        
        // Make window transparent
        self.window!.isOpaque = false;
        // self.window!.hasShadow = false
        self.window!.backgroundColor = NSColor.init(calibratedRed: 1, green: 1, blue: 1, alpha: 0.9);
    }
}
