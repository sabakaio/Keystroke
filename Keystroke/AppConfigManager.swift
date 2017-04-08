//
//  AppConfigManager.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import Yaml

private struct AppConfigFile {
    let url: URL
    let appName: String
    let contents: String
}

public struct AppConfig {
    let appName: String
    let operations: [String: AppOperation]
    let bindings: Any
}

public struct AppOperation {
    let name: String
    let originalHotkey: String
}

class AppConfigManager: NSObject {
    private func getConfigURLsFromBundle() -> [URL]? {
        return Bundle.main.urls(forResourcesWithExtension: "keystroke", subdirectory: "")
    }
    
    private func loadFile(from url: URL) -> AppConfigFile? {
        do {
            let contents = try String(contentsOf: url, encoding: String.Encoding.utf8)
            return AppConfigFile(
                url: url,
                appName: url.deletingPathExtension().lastPathComponent,
                contents: contents
            )
        } catch {
            return nil
        }
    }
    
    private func parse(config file: AppConfigFile) -> AppConfig? {
        do {
            let value = try Yaml.load(file.contents)
            let operations = value.dictionary!["operations"]!.array!.map({
                op in AppOperation(
                    name: op.dictionary!["name"]!.string!,
                    originalHotkey: op.dictionary!["hotkey"]!.string!
                )
            }).reduce([String: AppOperation]()) { acc, op in
                var dict = acc
                dict[op.name] = op
                return dict
            }
            let bindings = value.dictionary!["bindings"]!.dictionary!
            return AppConfig(
                appName: file.appName,
                operations: operations,
                bindings: bindings
            )
        } catch {
            print(error)
            return nil
        }
    }
    
    public func loadConfigurationsFromBundle() {
        guard let urls = getConfigURLsFromBundle() else {return}
        
        for url in urls {
            guard let file = loadFile(from: url) else {continue}
            guard let appConfig = parse(config: file) else {continue}
            mainStore.dispatch(AppBindingsSetAction(appName: appConfig.appName, config: appConfig))
        }
    }
}
