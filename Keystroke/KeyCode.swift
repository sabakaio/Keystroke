//
//  KeyCode.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 08/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

public enum KeystrokeError: Error {
    case MultipleKeys(value: String)
    case UnknownFlag(value: String)
    case UnknownKey(value: String)
    case NoKey(value: String)
    case CannotConvertToString(value: KeyCode)
}

public enum KeyCode: UInt64 {
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
    
    static func from(letter: String) throws -> KeyCode {
        switch letter {
        case "a":
            return .Key_a
        case "b":
            return .Key_b
        case "c":
            return .Key_c
        case "d":
            return .Key_d
        case "e":
            return .Key_e
        case "f":
            return .Key_f
        case "g":
            return .Key_g
        case "h":
            return .Key_h
        case "i":
            return .Key_i
        case "j":
            return .Key_j
        case "k":
            return .Key_k
        case "l":
            return .Key_l
        case "m":
            return .Key_m
        case "n":
            return .Key_n
        case "o":
            return .Key_o
        case "p":
            return .Key_p
        case "q":
            return .Key_q
        case "r":
            return .Key_r
        case "s":
            return .Key_s
        case "t":
            return .Key_t
        case "u":
            return .Key_u
        case "v":
            return .Key_v
        case "w":
            return .Key_w
        case "x":
            return .Key_x
        case "y":
            return .Key_y
        case "z":
            return .Key_z
        default:
            throw KeystrokeError.UnknownKey(value: letter)
        }
    }
    
    func toLetter() throws -> String {
        switch self {
        case .Key_a:
            return "a"
        case .Key_b:
            return "b"
        case .Key_c:
            return "c"
        case .Key_d:
            return "d"
        case .Key_e:
            return "e"
        case .Key_f:
            return "f"
        case .Key_g:
            return "g"
        case .Key_h:
            return "h"
        case .Key_i:
            return "i"
        case .Key_j:
            return "j"
        case .Key_k:
            return "k"
        case .Key_l:
            return "l"
        case .Key_m:
            return "m"
        case .Key_n:
            return "n"
        case .Key_o:
            return "o"
        case .Key_p:
            return "p"
        case .Key_q:
            return "q"
        case .Key_r:
            return "r"
        case .Key_s:
            return "s"
        case .Key_t:
            return "t"
        case .Key_u:
            return "u"
        case .Key_v:
            return "v"
        case .Key_w:
            return "w"
        case .Key_x:
            return "x"
        case .Key_y:
            return "y"
        case .Key_z:
            return "z"
        default:
            throw KeystrokeError.CannotConvertToString(value: self)
        }
    }
}

struct Keystroke {
    private(set) var flags: CGEventFlags
    private(set) var keyCode: KeyCode
    
    func containsCommandFlag() -> Bool {
        return flags.contains(.maskCommand)
    }
    
    func containsControlFlag() -> Bool {
        return flags.contains(.maskControl)
    }
    
    func containsShiftFlag() -> Bool {
        return flags.contains(.maskShift)
    }
    
    func containsAltFlag() -> Bool {
        return flags.contains(.maskAlternate)
    }
    
    init(from config: String) throws {
        flags = CGEventFlags()
        
        let sections = config.components(separatedBy: "-")
        var letter: String? = nil
        
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
                    throw KeystrokeError.UnknownFlag(value: section)
                }
                guard letter == nil else {
                    throw KeystrokeError.MultipleKeys(value: config)
                }
                letter = section
            }
        }
        
        guard letter != nil else {
            throw KeystrokeError.NoKey(value: config)
        }
        
        keyCode = try KeyCode.from(letter: letter!)
    }
    
    func getEventKeycode() -> Int64 {
        return Int64(keyCode.rawValue)
    }
}
