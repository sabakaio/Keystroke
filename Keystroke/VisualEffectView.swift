//
//  VisualEffectView.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 08/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class VisualEffectView: NSVisualEffectView {
    
    override var allowsVibrancy: Bool { return true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
