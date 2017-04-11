//
//  WindowReducer.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

func windowReducer(state: WindowState?, _ action: Action) -> WindowState {
    
    // if no state has been provided, create the default state
    var state = state ?? WindowState()
    
    switch action {
    case _ as WindowHideAction:
        state.visible = false
    case let action as KeyEventWindowAction:
        if [.leftMouseDown].contains(action.type) {
            if state.visible {
                // Don't trigger on cmd+click
                state.skipNextShowTrigger = true
                return state
            }
        }
        
        let keyCode = action.event.getIntegerValueField(.keyboardEventKeycode)
        let flags = action.event.flags
        let hasCommand = flags.contains(CGEventFlags.maskCommand)
        
        state.appName = action.appName
        
        if keyCode == 53 && state.visible {
            // hide with escape
            state.visible = false
        }
        
        if keyCode != 53 && keyCode != 55 && !state.visible && hasCommand {
            // Skip on cmd+something (e.g cmd+tab)
            state.skipNextShowTrigger = true
            return state
        }
        
        if keyCode == 55 {
            if state.visible {
                if !hasCommand {
                    state.visible = false
                }
            } else {
                if !hasCommand {
                    if !state.skipNextShowTrigger {
                        state.visible = true
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



