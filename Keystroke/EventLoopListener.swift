//
//  EventLoopManager.swift
//  Keystroke
//
//  Created by Anton Egorov on 11/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Foundation
import Cocoa

fileprivate func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
    switch type {
    case .keyDown:
        let keyCode = KeyCode.from(event: event)
        print("keyDown " + String(describing: keyCode))
    case .flagsChanged:
        print("flagsChanged")
    case .leftMouseDown:
        print("leftMouseDown")
    default:
        print("NOT EXPECTED EVENT TYPE", String(describing: type))
        return Unmanaged.passRetained(event)
    }
    
    let windowWasVisible = mainStore.state.window.visible
    
    // Process event to update window visibility state
    mainStore.dispatch(
        ComputeWindowStateForIOEvent(type: type, event: event)
    )
    
    // Bypass event if window is not active
    let windowShouldBecomeVisible = mainStore.state.window.visible
    if !windowShouldBecomeVisible {
        return Unmanaged.passRetained(event)
    }
    
    // Do not lock mouse
    if type == .leftMouseDown {
        return Unmanaged.passRetained(event)
    }
    
    //
    // Keystroke window is opened. Prevent key event propagating to original application.
    // Handle key event code to get an operation to execute of change a keyboard layout.
    //
    
    // Init a keyboard on become visible and start blocking event propagation
    if !windowWasVisible, windowShouldBecomeVisible {
        let appName = NSWorkspace.shared().frontmostApplication!.localizedName!
        mainStore.dispatch(InitKeyboardForApp(appName: appName))
        return nil
    }
    
    if type != .keyDown {
        return nil
    }
    
    // Update keyboad layout with next level or get an oparation to perform
    mainStore.dispatch(
        KeyEventBindingAction(type: type, event: event)
    )
    
    guard let operation = mainStore.state.keyboard.operation else { return nil }
    print("=> \(operation.name)")
    
    // Hide main window, all done
    mainStore.dispatch(WindowHideAction())
    
    // Execute Apple Script for the operation, disable handling CMD temporary
    mainStore.dispatch(WindowStopListenTrigger())
    operation.script.execute()
    mainStore.dispatch(WindowStartListenTrigger())
    
    return nil
}

public class EventLoopListener: NSObject {
    private var keyListener: CFMachPort? = nil
    
    public func start() {
        func callback(
            proxy: OpaquePointer,
            type: CGEventType,
            event: CGEvent,
            refcon: UnsafeMutableRawPointer?
            ) -> Unmanaged<CGEvent>? {

            return handleEvent(type: type, event: event)
        }
        
        let eventMask = CGEventMask(0
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.leftMouseDown.rawValue))
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: bridge(obj: self)) else {
                print("failed to create event tap")
                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        keyListener = eventTap
        CFRunLoopRun()
    }
    
    public func stop() {
        CGEvent.tapEnable(tap: keyListener!, enable: false)
    }
    
    public func restart(for event: CGEvent) -> Unmanaged<CGEvent> {
        stop()
        start()
        return Unmanaged.passRetained(event)
    }
}
