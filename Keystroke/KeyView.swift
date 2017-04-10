//
//  KeyView.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 10/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class KeyView: NSTextField {
    var padding: CGFloat = 10.0
    
    override func draw(_ dirtyRect: NSRect) {
        let rect = NSRect(
            x: dirtyRect.origin.x + padding,
            y: dirtyRect.origin.y + padding,
            width: dirtyRect.size.width + padding,
            height: dirtyRect.size.height + padding
        )
        super.draw(rect)
    }
}
