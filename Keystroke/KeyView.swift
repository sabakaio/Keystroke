//
//  KeyView.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 10/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class KeyView: NSTextField {
    static func create() -> KeyView {
        let view = KeyView.newAutoLayout()
        
        view.isEditable = false
        view.isBezeled = false
        view.drawsBackground = false
        view.translatesAutoresizingMaskIntoConstraints = true
        view.wantsLayer = true
        view.alignment = .center
        view.usesSingleLineMode = true
        
        view.backgroundColor = NSColor.clear
        
        return view
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
