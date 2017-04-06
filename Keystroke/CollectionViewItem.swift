//
//  CollectionViewItem.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    
    var actionText: String? = "" {
        didSet {
            guard isViewLoaded else { return }
            if let actionText = actionText {
                textField?.stringValue = actionText
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        // view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
}
