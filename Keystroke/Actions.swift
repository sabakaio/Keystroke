//
//  Actions.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct ThemeActionToggle: Action {}

struct BindingsOperationAddAction: Action {
    let appName: String
    let operationName: String
    let hotkey: String
}

struct KeyEventAction: Action {
    let appName: String
    let type: CGEventType
    let event: CGEvent
}

func handleKeyEvent(type: CGEventType, event: CGEvent) -> Action {
    let appName = NSWorkspace.shared().frontmostApplication?.localizedName
    return KeyEventAction(appName: appName!, type: type, event: event)
}
