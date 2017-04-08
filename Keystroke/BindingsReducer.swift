//
//  BindingsReducer.swift
//  Keystroke
//
//  Created by Anton Egorov on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

func bindingsReducer(state: BindingsState?, _ action: Action) -> BindingsState {
    var state = state ?? BindingsState()
    
    switch action {
    case let action as AppBindingsSetAction:
        state.apps[action.appName] = action.config
    default:
        break
    }
    
    return state
}
