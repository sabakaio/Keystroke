//
//  ThemeReducer.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

func themeReducer(state: ThemeState?, action: Action) -> ThemeState {
    
    // if no state has been provided, create the default state
    var state = state ?? ThemeState()
    
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
