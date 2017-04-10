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
        
        // Remember latest event to pass through
        state.lastEvent = event
        
        // Do nothing if Keystroke main window is inactive
        guard mainStore.state.view.windowVisible else {
            guard state.appName == nil else { return KeyboardState() }
            return state
        }
        
        // Dont propagate event while going throuth bindings tree
        state.lastEvent = nil
        
        // Should handle 'key down' events with a proper key code only
        let keyCode = KeyCode.from(event: event)
        guard [.keyDown].contains(type) && keyCode != nil else {
            return state
        }
        
        // Reset strokes sequence and keyboard layout if current app changed
        if state.appName != appName {
            state.appName = appName
            state.strokes = []
            
            // Get app specific bindings or reset
            guard let config = mainStore.state.bindings.apps[appName] else {
                state.bindings = nil
                return state
            }
            state.bindings = config.bindings
        }
        
        // Get to next level, if exists
        guard let nextLevel = state.bindings?.bindings[keyCode!] else {
            // Nothing to do
            return state
        }
        
        // Breadcrumbs
        state.strokes.append(keyCode!)
        
        // Check for next bindings level or get operation to perform
        guard let nextLevelFolder = nextLevel as? AppBindingsConfigFolder else {
            // This is an operation, mutate event
            let operation = (nextLevel as! AppBindingsConfigOperation).operation
            let newEvent = event.copy()
            newEvent!.setIntegerValueField(.keyboardEventKeycode, value: Int64(operation.keyCode!.rawValue))
            newEvent!.flags = operation.flags
            state.lastEvent = newEvent
            return state
        }
        state.bindings = nextLevelFolder
        
        return state
    default:
        return state
    }
}
