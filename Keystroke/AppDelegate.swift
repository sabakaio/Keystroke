//
//  AppDelegate.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import ReSwift

// The global application store, which is responsible for managing the appliction state.
let mainStore = Store<AppState>(
    reducer: AppReducer(),
    state: nil
)

let appConfigManager = AppConfigManager()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var keyListener: CFMachPort? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // First load configurations from files
        appConfigManager.loadConfigurationsFromBundle()
        keyListener = startKeyListener()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        CGEvent.tapEnable(tap: keyListener!, enable: false)
    }
    
    
    func startKeyListener() -> CFMachPort {
        func callback(
            proxy: OpaquePointer,
            type: CGEventType,
            event: CGEvent,
            refcon: UnsafeMutableRawPointer?
            ) -> Unmanaged<CGEvent>? {
            
            handleKeyEvent(type: type, event: event)
            
            // Check event to popagate
            guard let newEvent = mainStore.state.keyboard.lastEvent else { return nil }
            // Hide main window
            mainStore.dispatch(WindowHideAction())
            
            return Unmanaged.passRetained(newEvent)
        }
        
        let eventMask =
            (1 << CGEventType.keyDown.rawValue)
                | (1 << CGEventType.keyUp.rawValue)
                | (1 << CGEventType.flagsChanged.rawValue)
                | (1 << CGEventType.leftMouseDown.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: nil) else {
                print("failed to create event tap")
                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        return eventTap
        //CFRunLoopRun()
    }
}

