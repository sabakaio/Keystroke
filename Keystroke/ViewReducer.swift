//
//  ViewReducer.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

func viewReducer(state: ViewState?, _ action: Action) -> ViewState {
    
    // if no state has been provided, create the default state
    var state = state ?? ViewState()
    
    switch action {
    case let action as KeyEventAction:
        if [.leftMouseDown].contains(action.type) {
            if state.windowVisible {
                // Don't trigger on cmd+click
                state.skipNextShowTrigger = true
                return state
            }
        }
        
        let keyCode = action.event.getIntegerValueField(.keyboardEventKeycode)
        let flags = action.event.flags
        let hasCommand = flags.contains(CGEventFlags.maskCommand)
        print(action.appName, keyCode.description, hasCommand)
        
        state.appName = action.appName
        
        if keyCode == 53 && state.windowVisible {
            // hide with escape
            state.windowVisible = false
        }
        
        if keyCode != 53 && keyCode != 55 && !state.windowVisible && hasCommand {
            // Skip on cmd+something (e.g cmd+tab)
            state.skipNextShowTrigger = true
            return state
        }
        
        if keyCode == 55 {
            if state.windowVisible {
                if !hasCommand {
                    state.windowVisible = false
                }
            } else {
                if !hasCommand {
                    if !state.skipNextShowTrigger {
                        state.windowVisible = true
                    } else {
                        state.skipNextShowTrigger = false
                    }
                }
            }
        }
    default:
        break
    }
    
    return state
}



