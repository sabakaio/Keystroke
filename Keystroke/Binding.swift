//
//  Binding.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class Binding: NSObject {
    fileprivate(set) var bindingKey: String = ""
    fileprivate(set) var descriptionText: String = ""
    
    
    init(binding: String, description: String) {
        bindingKey = binding
        descriptionText = description
    }
}
