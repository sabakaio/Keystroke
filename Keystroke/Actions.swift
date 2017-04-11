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

func handleKeyEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
    let appName = NSWorkspace.shared().frontmostApplication!.localizedName!
    let windowWasVisible = mainStore.state.window.visible
    
    // Process event to update window state (e.g. visibility)
    mainStore.dispatch(
        ComputeWindowStateForIOEvent(appName: appName, type: type, event: event)
    )
    
    // Bypass event if window is not active
    let windowShouldBecomeVisible = mainStore.state.window.visible
    if !windowShouldBecomeVisible {
        return Unmanaged.passRetained(event)
    }
    
    // Do not lock mouse
    if type == .leftMouseDown {
        return Unmanaged.passRetained(event)
    }
    
    // Init a keyboard on become visible and start blocking event propagation
    if !windowWasVisible, windowShouldBecomeVisible {
        mainStore.dispatch(InitKeyboardForApp(appName: appName))
        return nil
    }
    
    // Update keyboad layout with next level or get an oparation to perform
    mainStore.dispatch(
        KeyEventBindingAction(type: type, event: event)
    )
    
    guard let operation = mainStore.state.keyboard.operation else { return nil }
    
    // Create new event based on requested operation
    let newEvent = event.copy()
    let newCode = Int64(operation.keyCode!.rawValue)
    newEvent!.setIntegerValueField(.keyboardEventKeycode, value: newCode)
    newEvent!.flags = operation.flags
    
    // Hide main window, all done
    mainStore.dispatch(WindowHideAction())
    
    return Unmanaged.passRetained(newEvent!)
}
