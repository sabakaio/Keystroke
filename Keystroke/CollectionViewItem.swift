//
//  CollectionViewItem.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import ReSwift

class CollectionViewItem: NSCollectionViewItem, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    var actionText: String? = "" {
        didSet {
            guard isViewLoaded else { return }
            if let actionText = actionText {
                textField?.stringValue = actionText
                textField?.backgroundColor = NSColor.clear
            }
        }
    }
    
    func activateTheme(theme: Theme) {
        textField?.textColor = NSColor.init(
            calibratedRed: theme.actionColor.calibratedRed,
            green: theme.actionColor.green,
            blue: theme.actionColor.blue,
            alpha: theme.actionColor.alpha
        );
    }
    
    func newState(state: AppState) {
        activateTheme(theme: state.theme)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        mainStore.subscribe(self)
        // view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
}
