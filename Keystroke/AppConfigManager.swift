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

// Todo: prepare a better parsed structure
public struct AppConfig {
    let appName: String
    let operations: Any
    let bindings: Any
}

class AppConfigManager: NSObject {
    private(set) var configuations: [AppConfig] = []
    
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
            let opeations = value.dictionary!["operations"]!.array!
            let bindings = value.dictionary!["bindings"]!.dictionary!
            return AppConfig(
                appName: file.appName,
                operations: opeations,
                bindings: bindings
            )
        } catch {
            print(error)
            return nil
        }
    }
    
    public func loadConfigurationsFromBundle() {
        guard let urls = getConfigURLsFromBundle() else {return}
        
        if configuations.count > 0 {
            configuations.removeAll()
        }
        
        for url in urls {
            guard let file = loadFile(from: url) else {continue}
            guard let appConfig = parse(config: file) else {continue}
            configuations.append(appConfig)
        }
    }
}
