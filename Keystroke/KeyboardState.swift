//
//  KeyboardState.swift
//  Keystroke
//
//  Created by Anton Egorov on 09/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct KeyboardState: StateType {
    var keys: [KeyCode: KeyboardKey]
    var initialKeys: [KeyCode: KeyboardKey]
    var appName: String? = nil
    var strokes: [KeyCode] = [KeyCode]()
    var bindings: AppBindingsConfigFolder? = nil
    var lastEvent: CGEvent? = nil
    
    init() {
        initialKeys = [
            KeyCode.Key_q,
            KeyCode.Key_w,
            KeyCode.Key_e,
            KeyCode.Key_r,
            KeyCode.Key_t,
            KeyCode.Key_y,
            KeyCode.Key_u,
            KeyCode.Key_i,
            KeyCode.Key_o,
            KeyCode.Key_p,
            KeyCode.Key_a,
            KeyCode.Key_s,
            KeyCode.Key_d,
            KeyCode.Key_f,
            KeyCode.Key_g,
            KeyCode.Key_h,
            KeyCode.Key_j,
            KeyCode.Key_k,
            KeyCode.Key_l,
            KeyCode.Key_z,
            KeyCode.Key_x,
            KeyCode.Key_c,
            KeyCode.Key_v,
            KeyCode.Key_b,
            KeyCode.Key_n,
            KeyCode.Key_m
            ].reduce([KeyCode: KeyboardKey](), { result, key in
                var result = result
                result[key] = KeyboardKey(code: key)
                return result
            })
        keys = initialKeys
    }
    
    mutating func updateWith(bindings bindingsConfig: AppBindingsConfigFolder?) {
        bindings = bindingsConfig
        
        // Reset current keyboard keys
        keys = initialKeys
        guard bindings != nil else { return }
        
        // Go through bindings configuration to update key title and type
        for (code, config) in bindingsConfig!.bindings {
            keys[code]!.title = config.name
            switch config {
            case _ as AppBindingsConfigFolder:
                keys[code]!.type = .Folder
            case _ as AppBindingsConfigOperation:
                keys[code]!.type = .Operation
            default:
                break
            }
        }
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
    
    init(code: KeyCode, keyTitle: String? = nil, type keyType: KeyboardKeyType = KeyboardKeyType.Empty) {
        name = try! code.toLetter()
        if keyTitle == nil {
            title = name
        } else {
            title = keyTitle!
        }
        type = keyType
    }
}
