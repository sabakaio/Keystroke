//
//  Utils.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

func bridge<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func transfer<T : AnyObject>(ptr : UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

func calculateSize(of text: String, using font: NSFont) -> NSSize {
    let attributes = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
    let sizeOfText = text.size(withAttributes: attributes as! [String : Any])
    return sizeOfText
}
