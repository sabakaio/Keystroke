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

enum HandleKeyError: Error {
    case UnsupportedEventType(type: CGEventType)
}

func handleKeyEvent(type: CGEventType, event: CGEvent) throws {
    let appName = NSWorkspace.shared().frontmostApplication!.localizedName!
    let windowWasVisible = mainStore.state.window.visible
    let skipNextShowTrigger = mainStore.state.window.skipNextShowTrigger
    
    mainStore.dispatch(
        ComputeWindowStateForIOEvent(appName: appName, type: type, event: event)
    )
    
    let windowShouldBecomeVisible = mainStore.state.window.visible
    let shouldSkipThisTrigger = mainStore.state.window.skipNextShowTrigger
    
    if skipNextShowTrigger || shouldSkipThisTrigger {
        mainStore.dispatch(
            PassEventUnchanged(type: type, event: event)
        )
        return
    }
    
    switch type {
    case .leftMouseDown:
        mainStore.dispatch(
            PassEventUnchanged(type: type, event: event)
        )
    case .flagsChanged, .keyUp, .keyDown:
        print("Window was visible: \(windowWasVisible), Window should become visible: \(windowShouldBecomeVisible), Skip: \(shouldSkipThisTrigger)")
        
        if !windowWasVisible, windowShouldBecomeVisible {
            mainStore.dispatch(InitKeyboardForApp(appName: appName))
        } else {
            mainStore.dispatch(
                PassEventUnchanged(type: type, event: event)
            )
        }
        
        if windowWasVisible {
            mainStore.dispatch(
                KeyEventBindingAction(type: type, event: event)
            )
        }
    default:
        throw HandleKeyError.UnsupportedEventType(type: type)
    }
}
