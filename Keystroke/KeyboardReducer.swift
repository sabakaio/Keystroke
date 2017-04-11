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
        
    case _ as WindowHideAction:
        state.strokes = []
        state.operation = nil
        
    case let action as InitKeyboardForApp:
        let appName = action.appName
        // Reset strokes sequence and keyboard layout if current app changed
        // TODO: Maybe our cmd-tab bug is here?
        state.appName = appName
        state.strokes = []
        state.operation = nil
        
        // Get app specific bindings or reset
        guard let config = mainStore.state.bindings.apps[appName] else {
            state.updateWith(bindings: nil)
            return state
        }
        state.updateWith(bindings: config.bindings)
        
    case let action as KeyEventBindingAction:
        // Do nothing if Keystroke main window is inactive
        if !mainStore.state.window.visible {
            return state
        }
        
        let type = action.type, event = action.event
        
        // Should handle 'key down' events with a proper key code only
        let keyCode = KeyCode.from(event: event)
        guard [.keyDown].contains(type) && keyCode != nil else {
            return state
        }
        
        // Go to next level, if exists
        guard let nextLevel = state.bindings?.bindings[keyCode!] else {
            // Nothing to do
            return state
        }
        
        // Breadcrumbs
        state.strokes.append(keyCode!)
        
        // Check for next bindings level or get operation to perform
        guard let nextLevelFolder = nextLevel as? AppBindingsConfigFolder else {
            // This is an operation
            state.operation = (nextLevel as! AppBindingsConfigOperation).operation
            return state
        }
        state.updateWith(bindings: nextLevelFolder)
        
    default:
        break
    }
    
    return state
}
