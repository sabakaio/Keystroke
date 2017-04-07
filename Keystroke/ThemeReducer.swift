//
//  ThemeReducer.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

// the reducer is responsible for evolving the application state based
// on the actions it receives
struct ThemeReducer: Reducer {
    typealias ReducerStateType = AppState
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        
        // if no state has been provided, create the default state
        var state = state ?? AppState()
        
        switch action {
        case _ as ThemeActionToggle:
            if state.theme.name == "dark" {
                state.theme = LightTheme
            } else {
                state.theme = DarkTheme
            }
        default:
            break
        }
        
        return state
    }
    
}
