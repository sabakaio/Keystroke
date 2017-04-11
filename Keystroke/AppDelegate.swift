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
    state: AppState()
)

let appConfigManager = AppConfigManager()
let eventLoopListener = EventLoopListener()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // First load configurations from files
        appConfigManager.loadConfigurationsFromBundle()
        eventLoopListener.start()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        eventLoopListener.stop()
    }
}
