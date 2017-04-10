//
//  Actions.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct ThemeActionToggle: Action {}

struct WindowHideAction: Action {}

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
    let type: CGEventType
    let event: CGEvent
}

struct KeyboardInitAction: Action {
    let appName: String
}

func handleKeyEvent(type: CGEventType, event: CGEvent) {
    let appName = NSWorkspace.shared().frontmostApplication?.localizedName
    let windowVisible = mainStore.state.view.windowVisible
    
    mainStore.dispatch(
        KeyEventWindowAction(appName: appName!, type: type, event: event)
    )
    
    if !windowVisible && mainStore.state.view.windowVisible {
        mainStore.dispatch(KeyboardInitAction(appName: appName!))
    }
    
    mainStore.dispatch(
        KeyEventBindingAction(type: type, event: event)
    )
}
