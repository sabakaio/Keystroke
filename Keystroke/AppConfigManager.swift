//
//  AppConfigManager.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa
import Yaml
import Hydra

private struct AppConfigFile {
    let url: URL
    let appName: String
    let contents: String
}

public struct AppConfig {
    let appName: String
    let operations: [String: AppOperation]
    let bindings: AppBindingsConfigFolder
}

public struct AppOperation {
    let name: String
    let script: AppleScript
    
    init(_ operationName: String, tell appName: String, keystroke config: String) throws {
        name = operationName
        let keystroke = try Keystroke(for: config)
        script = try AppleScript(tell: appName, to: keystroke)
    }
    
    init(_ operationName: String, tell appName: String, pressMenu config: [String]) throws {
        name = operationName
        script = try AppleScript(tell: appName, pressMenu: config)
    }
}

public protocol AppBindingsConfig {
    var name: String { get set }
}

public struct AppBindingsConfigOperation: AppBindingsConfig {
    public var name: String
    let operation: AppOperation
}

public struct AppBindingsConfigFolder: AppBindingsConfig {
    public var name: String
    let bindings: [KeyCode: AppBindingsConfig]
    
    public func printTree(level: Int = 0) {
        let indent = level * 4
        for (key, config) in bindings {
            let prefix = String(repeating: " ", count: indent) + String(describing: key) + ":"
            guard let subfolder = config as? AppBindingsConfigFolder else {
                let operation = config as! AppBindingsConfigOperation
                print(prefix + " " + operation.name)
                continue
            }
            print(prefix)
            subfolder.printTree(level: level + 1)
        }
    }
}

class AppConfigManager: NSObject {
    private func getConfigURLsFromBundle() -> [URL]? {
        return Bundle.main.urls(forResourcesWithExtension: "keystroke", subdirectory: "")
    }
    
    private func loadFile(from url: URL) -> Promise<AppConfigFile> {
        return Promise<AppConfigFile>(in: .background, { resolve, reject in
            do {
                let contents = try String(contentsOf: url, encoding: String.Encoding.utf8)
                resolve(AppConfigFile(
                    url: url,
                    appName: url.deletingPathExtension().lastPathComponent,
                    contents: contents
                ))
            } catch {
                reject(error)
            }
        })
    }
    
    private func parse(config file: AppConfigFile) -> Promise<AppConfig> {
        return Promise<AppConfig>(in: .background, { resolve, reject in
            do {
                let value = try Yaml.load(file.contents)
                
                // Extract list of Application Operations
                let operations = try value.dictionary!["operations"]!.array!.map({
                    (operation: Yaml) throws -> AppOperation in
                    // Expect hotkey configured for operation, look for menu item to press instead
                    guard let hotKey = operation.dictionary!["hotkey"] else {
                        let menu = operation.dictionary!["menu"]!.array!
                        return try AppOperation(
                            operation.dictionary!["name"]!.string!,
                            tell: file.appName,
                            pressMenu: menu.map { item in item.string! }
                        )
                    }
                    return try AppOperation(
                        operation.dictionary!["name"]!.string!,
                        tell: file.appName,
                        keystroke: hotKey.string!
                    )
                }).reduce([String: AppOperation]()) { accumulator, operation in
                    var dict = accumulator
                    dict[operation.name] = operation
                    return dict
                }
                
                // Create a bindings tree
                func toBindingsConfig(name: String, value: [Yaml]) throws -> AppBindingsConfig {
                    let currentLevel = try value.reduce([KeyCode: AppBindingsConfig](), {
                        (result, value) throws -> [KeyCode: AppBindingsConfig] in
                        var result = result
                        
                        // Parse key config, extract a name and a key code
                        let config = value.dictionary!
                        let letter = config["key"]!.string!
                        let name = config["name"]!.string!
                        let keyCode = try KeyCode.from(letter: letter)
                        
                        // Is it a folder? Treat as an operation otherwise
                        guard let subfolder = config["bindings"]?.array else {
                            let operation = config["operation"]!.string!
                            result[keyCode] = AppBindingsConfigOperation(
                                name: name,
                                operation: operations[operation]!
                            )
                            return result
                        }
                        
                        // Go to a recursion to parse next level
                        result[keyCode] = try toBindingsConfig(name: name, value: subfolder)
                        return result
                    })
                    return AppBindingsConfigFolder(
                        name: name,
                        bindings: currentLevel
                    )
                }
                let bindings = try toBindingsConfig(
                    name: file.appName,
                    value: value.dictionary!["bindings"]!.array!
                    ) as! AppBindingsConfigFolder
                
                bindings.printTree()
                
                resolve(AppConfig(
                    appName: file.appName,
                    operations: operations,
                    bindings: bindings
                ))
            } catch {
                reject(error)
            }
        })
    }
    
    public func loadConfigurationsFromBundle() {
        guard let urls = getConfigURLsFromBundle() else {return}
        
        for url in urls {
            loadFile(from: url).then(parse).then(in: .main, { appConfig in
                mainStore.dispatch(AppBindingsSetAction(appName: appConfig.appName, config: appConfig))
            }).catch(in: .main, { error in
                print(error)
            })
        }
    }
}
