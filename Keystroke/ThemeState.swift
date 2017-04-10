//
//  ThemeState.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

let DarkTheme = Theme(
    name: "dark",
    backgroundColor: RGBA(calibratedRed: 0.2, green: 0.2, blue: 0.2, alpha: 1),
    actionColor: RGBA(calibratedRed: 0.607, green: 0.607, blue: 0.607, alpha: 1)
)

let LightTheme = Theme(
    name: "light",
    backgroundColor: RGBA(calibratedRed: 1, green: 1, blue: 1, alpha: 0.9),
    actionColor: RGBA(calibratedRed: 0.356, green: 0.615, blue: 0.968, alpha: 1)
)

struct ThemeState: StateType {
    var theme: Theme = DarkTheme
}

struct RGBA {
    public var calibratedRed: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat
    
    func asNSColor() -> NSColor {
        return NSColor.init(
            calibratedRed: self.calibratedRed,
            green: self.green,
            blue: self.blue,
            alpha: self.alpha
        )
    }
}

struct Theme {
    public var name: String
    public var backgroundColor: RGBA
    public var actionColor: RGBA
}
