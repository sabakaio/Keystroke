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
        startKeyListener()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        CGEvent.tapEnable(tap: keyListener!, enable: false)
    }
    
    
    func startKeyListener() {
        func callback(
            proxy: OpaquePointer,
            type: CGEventType,
            event: CGEvent,
            refcon: UnsafeMutableRawPointer?
            ) -> Unmanaged<CGEvent>? {
            
            switch type {
            case .keyDown:
                print("keyDown")
            case .keyUp:
                print("keyUp")
            case .flagsChanged:
                print("flagsChanged")
            case .leftMouseDown:
                print("leftMouseDown")
            case .tapDisabledByTimeout:
                print("tapDisabledByTimeout")
                let application: AppDelegate = transfer(ptr: refcon!)
                application.startKeyListener()
            case .tapDisabledByUserInput:
                print("tapDisabledByUserInput")
                let application: AppDelegate = transfer(ptr: refcon!)
                application.startKeyListener()
            default:
                // The mask accepts all events so we need to pass 
                // the events we don't care about as early as possible.
                // Not even register them in our state
                return Unmanaged.passRetained(event)
            }
            
            handleKeyEvent(type: type, event: event)
            
            // Check event to popagate
            guard let newEvent = mainStore.state.keyboard.lastEvent else { return nil }
            // Hide main window
            mainStore.dispatch(WindowHideAction())
            
            return Unmanaged.passRetained(newEvent)
        }
        
        // All events
        let eventMask = ~CGEventMask.allZeros
        
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
        //CFRunLoopRun()
    }
}

