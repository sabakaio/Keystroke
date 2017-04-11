//
//  KeyContainerView.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 11/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

let ANIMATION_DURATION = 0.1

class KeyContainerView: NSView {
    private var widthDimensionReference: NSLayoutConstraint? = nil
    private var centerPinReference: NSLayoutConstraint? = nil
    
    func setOrUpdateWidthDimension(_ width: CGFloat) {
        if widthDimensionReference == nil {
            widthDimensionReference = self.autoSetDimension(.width, toSize: width)
        } else {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = ANIMATION_DURATION
                widthDimensionReference!.animator().constant = width
            })
        }
    }
    
    func setOrUpdatePinForCentering(withInset inset: CGFloat) {
        if centerPinReference == nil {
            centerPinReference = self.autoPinEdge(toSuperviewEdge: .left, withInset: inset)
        } else {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = ANIMATION_DURATION
                centerPinReference!.animator().constant = inset
            })
        }
    }
    
    static func create(in parentView: RowView, after prevKeyContainer: KeyContainerView?) -> KeyContainerView {
        let view = KeyContainerView.newAutoLayout()
        
        view.translatesAutoresizingMaskIntoConstraints = true
        view.wantsLayer = true
        
        let layer = view.layer!
        layer.borderWidth = 1.5
        layer.borderColor = mainStore.state.theme.theme.emptyColor.asNSColor().cgColor
        layer.cornerRadius = 4
        
        parentView.addSubview(view)
        
        view.autoPinEdge(toSuperviewEdge: .top)
        view.autoSetDimension(.height, toSize: KEY_SIZE.height)
        
        if let prevContainer = prevKeyContainer {
            view.autoPinEdge(.left, to: .right, of: prevContainer, withOffset: KEY_SPACING)
        }
        
        return view
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
