//
//  KeyboardLayout.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 09/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class KeyboardLayout: NSCollectionViewFlowLayout {
    override init() {
        super.init()
        self.itemSize = NSSize(width: 50.0, height: 50.0)
        self.sectionInset = EdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        self.minimumInteritemSpacing = 10.0
        self.minimumLineSpacing = 10.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        var layoutAttributes = super.layoutAttributesForElements(in: rect)
        return layoutAttributes
    }
}
