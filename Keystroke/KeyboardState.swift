//
//  KeyboardState.swift
//  Keystroke
//
//  Created by Anton Egorov on 09/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct KeyboardState: StateType {
    var keys: [KeyboardKey]
    
    init() {
        keys = [
            "q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
            "a", "s", "d", "f", "g", "h", "j", "k", "l",
            "z", "x", "c", "v", "b", "n", "m"
            ].map({ key in
                KeyboardKey(name: key, title: key, type: KeyboardKeyType.Empty)
            })
    }
}

enum KeyboardKeyType {
    case Empty
    case Operation
    case Folder
}

struct KeyboardKey {
    var name: String
    var title: String
    var type: KeyboardKeyType
}
