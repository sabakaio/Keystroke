//
//  KeyCode.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 08/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

enum KeyCodeError: Error {
    case MultipleKeys(value: String)
    case UnknownFlag(value: String)
    case UnknownKey(value: String)
}

enum KeyCode: UInt64 {
    // Row 1
    case Key_BACKTICK = 50
    case Key_1 = 18
    case Key_2 = 19
    case Key_3 = 20
    case Key_4 = 21
    case Key_5 = 23
    case Key_6 = 22
    case Key_7 = 26
    case Key_8 = 28
    case Key_9 = 25
    case Key_0 = 29
    case Key_DASH = 27
    case Key_EQUALS = 24
    case Key_DELETE = 51

    // Row 2
    case Key_TAB = 48
    case Key_q = 12
    case Key_w = 13
    case Key_e = 14
    case Key_r = 15
    case Key_t = 17
    case Key_y = 16
    case Key_u = 32
    case Key_i = 34
    case Key_o = 31
    case Key_p = 35
    case Key_OPEN_SQUARE_BRACKET = 33
    case Key_CLOSE_SQUARE_BRACKET = 30

    // Row 3
    case Key_a = 0
    case Key_s = 1
    case Key_d = 2
    case Key_f = 3
    case Key_g = 5
    case Key_h = 4
    case Key_j = 38
    case Key_k = 40
    case Key_l = 37
    case Key_SEMICOLON = 41
    case Key_QUOTES = 39
    case Key_RETURN = 36

    // Row 4
    case Key_z = 6
    case Key_x = 7
    case Key_c = 8
    case Key_v = 9
    case Key_b = 11
    case Key_n = 45
    case Key_m = 46
    case Key_COMMA = 43
    case Key_DOT = 47
    case Key_SLASH = 44
    
    // Row 5
    case Key_SPACE = 49
    case Key_ARROW_LEFT = 123
    case Key_ARROW_RIGHT = 124
    case Key_ARROW_DOWN = 125
    case Key_ARROW_UP = 126
    
    case Key_COMMAND_LEFT = 55
    case Key_COMMAND_RIGHT = 54
    
    case Key_SHIFT_LEFT = 56
    case Key_SHIFT_RIGHT = 60
    
    case Key_CONTROL = 59
    
    case Key_OPTION_LEFT = 58
    case Key_OPTION_RIGHT = 61
    
    case Key_FN = 63
    
    static func from(event: CGEvent) -> KeyCode? {
        let eventCode = event.getIntegerValueField(.keyboardEventKeycode)
        return KeyCode(rawValue: UInt64(eventCode))
    }
    
    static func from(config: String) throws -> (flags: CGEventFlags, keyCode: KeyCode?) {
        let sections = config.components(separatedBy: "-")
        var flags = CGEventFlags()
        var letter: String? = nil
        var code: KeyCode? = nil
        
        for section in sections {
            switch section {
            case "cmd", "command":
                flags = flags.union(.maskCommand)
            case "ctrl", "control":
                flags = flags.union(.maskControl)
            case "alt", "option":
                flags = flags.union(.maskAlternate)
            case "shift":
                flags = flags.union(.maskShift)
            default:
                guard section.characters.count == 1 else {
                    throw KeyCodeError.UnknownFlag(value: section)
                }
                guard letter == nil else {
                    throw KeyCodeError.MultipleKeys(value: config)
                }
                letter = section
            }
        }
        
        guard letter != nil else { return (flags, nil) }
        
        switch letter! {
        case "a":
            code = .Key_a
        case "b":
            code = .Key_b
        case "c":
            code = .Key_c
        case "d":
            code = .Key_d
        case "e":
            code = .Key_e
        case "f":
            code = .Key_f
        case "g":
            code = .Key_g
        case "h":
            code = .Key_h
        case "i":
            code = .Key_i
        case "j":
            code = .Key_j
        case "k":
            code = .Key_k
        case "l":
            code = .Key_l
        case "m":
            code = .Key_m
        case "n":
            code = .Key_n
        case "o":
            code = .Key_o
        case "p":
            code = .Key_p
        case "q":
            code = .Key_q
        case "r":
            code = .Key_r
        case "s":
            code = .Key_s
        case "t":
            code = .Key_t
        case "u":
            code = .Key_u
        case "v":
            code = .Key_v
        case "w":
            code = .Key_w
        case "x":
            code = .Key_x
        case "y":
            code = .Key_y
        case "z":
            code = .Key_z
        default:
            throw KeyCodeError.UnknownKey(value: letter!)
        }
        
        return (flags, code)
    }
}
