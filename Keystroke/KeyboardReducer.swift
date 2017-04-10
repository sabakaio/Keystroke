//
//  KeyboardReducer.swift
//  Keystroke
//
//  Created by Anton Egorov on 09/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

func keyboardReducer(state: KeyboardState?, _ action: Action) -> KeyboardState {
    var state = state ?? KeyboardState()
    
    switch action {
    case let action as KeyEventBindingAction:
        let appName = action.appName, type = action.type, event = action.event
        
        // Reset strokes sequence if current app changed
        if state.appName != appName {
            state.appName = appName
            state.strokes = []
        }
        
        // Do nothing if main window is inactive
        guard mainStore.state.view.windowVisible else {
            return state
        }
        
        // Should works for a 'key down' event of a proper key code only
        let keyCode = KeyCode.from(event: event)
        guard [.keyDown].contains(type) && keyCode != nil else {
            return state
        }
        
        state.strokes.append(keyCode!)
        
        return state
    default:
        return state
    }
}
