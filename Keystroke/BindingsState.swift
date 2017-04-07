//
//  BindingsState.swift
//  Keystroke
//
//  Created by Anton Egorov on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct BindingsState: StateType {
    var apps = [String: BindingsConfig]()
}

struct BindingsConfig {
    var operations: [String: Operation]
}

struct Operation {
    var name: String
    var originalHotkey: String
}
