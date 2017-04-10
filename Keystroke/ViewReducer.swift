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
    case let action as KeyEventWindowAction:
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
        // print(action.appName, keyCode.description, hasCommand)
        
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
    case let action as KeyEventBindingAction:
        let event = action.event, appName = action.appName, type = action.type
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        state.lastEvent = event
        guard let bindings = mainStore.state.bindings.apps[appName] else { return state }
        
        if state.windowVisible && [.keyDown].contains(type) {
            print(keyCode.description)
            if keyCode == 9 {
                // replace mnemonic cmd - v with cmd+shift+d, split
                event.setIntegerValueField(.keyboardEventKeycode, value: 2)
                event.flags = event.flags.union(CGEventFlags.maskCommand)
            } else if keyCode == 1 {
                // replace mnemonic cmd - s with cmd+d, vetical split
                event.setIntegerValueField(.keyboardEventKeycode, value: 2)
                event.flags = event.flags.union(CGEventFlags.maskCommand)
                event.flags = event.flags.union(CGEventFlags.maskShift)
            }
            
            //state.windowVisible = false
        }
        
        // state.lastEvent = event
    default:
        break
    }
    
    return state
}



