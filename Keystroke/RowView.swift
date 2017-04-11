//
//  RowView.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 11/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class RowView: NSView {
    private static func create(in parentView: NSView) -> RowView {
        let view = RowView.newAutoLayout()
        
        view.translatesAutoresizingMaskIntoConstraints = true
        view.wantsLayer = true
        
        parentView.addSubview(view)
        
        view.autoPinEdge(toSuperviewEdge: .left)
        view.autoPinEdge(toSuperviewEdge: .right)
        view.autoSetDimension(.height, toSize: KEY_SIZE.height)
        
        return view
    }
    
    static func createFirstRow(in parentView: NSView) -> RowView {
        let view = create(in: parentView)
        view.autoPinEdge(toSuperviewEdge: .top)
        return view
    }
    
    static func createNextRow(in parentView: NSView, after previousRow: RowView) -> RowView {
        let view = create(in: parentView)
        view.autoPinEdge(.top, to: .bottom, of: previousRow, withOffset: KEY_SPACING)
        return view
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
