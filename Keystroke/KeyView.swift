//
//  KeyView.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 10/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import BonMot

class KeyView: NSTextField {
    func setStringValue(for key: KeyboardKey, using styles: KeyStyles) {
        let highlightRange = key.title.lowercased().range(of: key.name.lowercased())
        let baseStyle: StringStyle
        var text = key.title

        switch key.type {
        case .Folder, .Operation:
            baseStyle = styles.plaintext.byAdding(
                .xmlRules([
                    .style("hl", styles.highlight),
                    ])
            )
            guard let range = highlightRange else { break }
            text.replaceSubrange(range, with: "<hl>\(key.name)</hl>")
        default:
            // .Empty
            baseStyle = styles.empty
        }
        
        self.attributedStringValue = text.styled(with: baseStyle)
    }
    
    static func create(in parentView: KeyContainerView, for key: KeyboardKey, using styles: KeyStyles) -> KeyView {
        let view = KeyView(labelWithString: "")
        
        view.isEditable = false
        view.isBezeled = false
        view.drawsBackground = false
        view.translatesAutoresizingMaskIntoConstraints = true
        view.wantsLayer = true
        view.alignment = .center
        view.usesSingleLineMode = true
        view.backgroundColor = NSColor.clear
        
        parentView.addSubview(view)
        view.setStringValue(for: key, using: styles)
        
        view.autoPinEdge(toSuperviewEdge: .top, withInset: 15.0)
        view.autoAlignAxis(toSuperviewAxis: .vertical)
        view.autoMatch(.width, to: .width, of: view.superview!, withOffset: 0.0)
        
        return view
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}

