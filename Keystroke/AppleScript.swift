//
//  AppleScript.swift
//  Keystroke
//
//  Created by Anton Egorov on 12/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Foundation

enum AppleScriptTempleteError: Error {
    case BuildError(source: String)
    case UnknownKeyCode(code: KeyCode)
}

struct AppleScript {
    private var script: NSAppleScript
    
    init(to keystroke: Keystroke) throws {
        guard let key = try? keystroke.keyCode.toLetter() else {
            throw AppleScriptTempleteError.UnknownKeyCode(code: keystroke.keyCode)
        }
        var operationScript = ""
            + "tell application \"System Events\" to keystroke \""
            + key
            + "\""
        if !keystroke.flags.isEmpty {
            var usingFlags = [String]()
            if keystroke.containsCommandFlag() {
                usingFlags.append("command down")
            }
            if keystroke.containsAltFlag() {
                usingFlags.append("option down")
            }
            if keystroke.containsShiftFlag() {
                usingFlags.append("shift down")
            }
            if keystroke.containsControlFlag() {
                usingFlags.append("control down")
            }
            operationScript += "using {" + usingFlags.joined(separator: ", ") + "}"
        }
        guard let appleScript = NSAppleScript(source: operationScript) else {
            throw AppleScriptTempleteError.BuildError(source: operationScript)
        }
        script = appleScript
    }
    
    func execute() {
        var error: NSDictionary?
        script.executeAndReturnError(&error)
    }
}
