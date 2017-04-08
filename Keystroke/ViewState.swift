//
//  ViewState.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import ReSwift

struct ViewState: StateType {
    var windowVisible: Bool = true
    var skipNextShowTrigger: Bool = false
    var appName: String? = nil
    var lastEvent: CGEvent? = nil
}
