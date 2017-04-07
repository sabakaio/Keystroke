//
//  WindowController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

struct RGBA {
    public var calibratedRed: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat
}

struct Theme {
    public var name: String
    public var backgroundColor: RGBA
    public var actionColor: RGBA
}

let DarkTheme = Theme(
    name: "dark",
    backgroundColor: RGBA(calibratedRed: 0.176, green: 0.176, blue: 0.176, alpha: 1),
    actionColor: RGBA(calibratedRed: 0.964, green: 0.752, blue: 0.313, alpha: 1)
)

class WindowController: NSWindowController {
    private(set) var activeTheme: Theme = DarkTheme
    
    func activateTheme(theme: Theme) {
        activeTheme = theme
        if let window = window {
            window.backgroundColor = NSColor.init(
                calibratedRed: theme.backgroundColor.calibratedRed,
                green: theme.backgroundColor.green,
                blue: theme.backgroundColor.blue,
                alpha: theme.backgroundColor.alpha
            );
        }
        
    }
    
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
                , display: true
            )
        
            // Set window floating on top
            window.level = Int(CGWindowLevelForKey(.maximumWindow))
            
            // A bad attemt to hide on startup
            window.orderOut(true)
            
            // Hide title
            window.titleVisibility = NSWindowTitleVisibility.hidden;
            window.titlebarAppearsTransparent = true;
            window.isMovableByWindowBackground  = true;
            
            // Hide top left buttons
            window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true;
            window.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = true;
            window.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = true;
            
            // Make window transparent
            // window.isOpaque = false;
            // self.window!.hasShadow = false
            activateTheme(theme: DarkTheme)
            
            
            // Try to move to active space, works for desktops
            // but doesnt work for fullscreen apps :(
            // see http://stackoverflow.com/questions/1740412/how-to-bring-nswindow-to-front-and-to-the-current-space
            NSApp.activate(ignoringOtherApps: true)
            window.collectionBehavior = .canJoinAllSpaces
        }
    }
}
