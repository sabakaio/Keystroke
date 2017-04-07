//
//  AppState.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct AppState: StateType {
    var theme: ThemeState = ThemeState()
}

struct KeyEvent {
    public var type: CGEventType
    public var event: CGEvent
}
