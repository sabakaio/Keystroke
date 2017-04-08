//
//  Actions.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct ThemeActionToggle: Action {}

struct AppBindingsSetAction: Action {
    let appName: String
    let config: AppConfig
}

struct KeyEventWindowAction: Action {
    let appName: String
    let type: CGEventType
    let event: CGEvent
}

struct KeyEventBindingAction: Action {
    let appName: String
    let type: CGEventType
    let event: CGEvent
}

func handleKeyEvent(type: CGEventType, event: CGEvent) -> Action {
    let appName = NSWorkspace.shared().frontmostApplication?.localizedName
    
    mainStore.dispatch(
        KeyEventWindowAction(appName: appName!, type: type, event: event)
    )
    
    
    return KeyEventBindingAction(appName: appName!, type: type, event: event)
}
