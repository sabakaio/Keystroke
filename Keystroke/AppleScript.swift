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
    case MenuPathIsTooShort(config: [String])
}

struct AppleScript {
    private var script: NSAppleScript
    
    init(tell appName: String, to keystroke: Keystroke) throws {
        guard let key = try? keystroke.keyCode.toLetter() else {
            throw AppleScriptTempleteError.UnknownKeyCode(code: keystroke.keyCode)
        }
        var operationScript = ""
            //+ "activate application \"\(appName)\"\n"
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
    
    init(tell appName: String, pressMenu config: [String]) throws {
        guard config.count > 1 else {
            throw AppleScriptTempleteError.MenuPathIsTooShort(config: config)
        }
        
        var menu = config
        let barItem = menu.remove(at: 0)
        let actionItem = menu.popLast()!
        
        var instructions = [
            "tell application \"System Events\"",
            "tell process \"\(appName)\"",
            "tell menu bar 1",
            "tell menu bar item \"\(barItem)\"",
            "tell menu \"\(barItem)\""
        ]
        for item in menu {
            instructions.append("tell menu item \"\(item)\"")
            instructions.append("tell menu \"\(item)\"")
        }
        
        var operationScript = instructions.joined(separator: "\n")
        operationScript += "\nclick menu item \"\(actionItem)\"\n"
        operationScript += instructions.map({_ in "end tell"}).joined(separator: "\n")
        
        guard let appleScript = NSAppleScript(source: operationScript) else {
            throw AppleScriptTempleteError.BuildError(source: operationScript)
        }
        script = appleScript
    }
    
    func execute() {
        var error: NSDictionary?
        script.executeAndReturnError(&error)
        if error != nil {
            print(error!)
        }
    }
}
