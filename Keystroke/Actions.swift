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
struct WindowStopListenTrigger: Action {}
struct WindowStartListenTrigger: Action {}

struct AppBindingsSetAction: Action {
    let appName: String
    let config: AppConfig
}

struct ComputeWindowStateForIOEvent: Action {
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
