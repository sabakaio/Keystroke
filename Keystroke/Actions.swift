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

struct PassEventUnchanged: Action {
    let type: CGEventType
    let event: CGEvent
}

struct AppBindingsSetAction: Action {
    let appName: String
    let config: AppConfig
}

struct ComputeWindowStateForIOEvent: Action {
    let appName: String
    let type: CGEventType
    let event: CGEvent
}

struct KeyEventBindingAction: Action {
    let type: CGEventType
    let event: CGEvent
}

struct InitKeyboardForApp: Action {
    let appName: String
}

func handleKeyEvent(type: CGEventType, event: CGEvent) {
    let appName = NSWorkspace.shared().frontmostApplication!.localizedName!
    let windowWasVisible = mainStore.state.window.visible
    
    mainStore.dispatch(
        ComputeWindowStateForIOEvent(appName: appName, type: type, event: event)
    )
    
    if type == .leftMouseDown {
        mainStore.dispatch(
            PassEventUnchanged(type: type, event: event)
        )
        return
    }
    
    let windowShouldBecomeVisible = mainStore.state.window.visible
    
    if !windowWasVisible, windowShouldBecomeVisible {
        mainStore.dispatch(InitKeyboardForApp(appName: appName))
    }
    
    mainStore.dispatch(
        KeyEventBindingAction(type: type, event: event)
    )
}
