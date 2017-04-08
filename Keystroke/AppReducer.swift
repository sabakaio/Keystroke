//
//  AppReducer.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

// the reducer is responsible for evolving the application state based
// on the actions it receives
struct AppReducer: Reducer {
    typealias ReducerStateType = AppState

    func handleAction(action: Action, state: AppState?) -> AppState {
        return AppState(
            theme: themeReducer(state: state?.theme, action),
            bindings: bindingsReducer(state: state?.bindings, action),
            view: viewReducer(state: state?.view, action)
        )
    }
}
