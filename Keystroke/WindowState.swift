//
//  WindowState.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct WindowState: StateType {
    var visible: Bool = true
    var skipNextShowTrigger: Bool = false
    var appName: String? = nil
}
