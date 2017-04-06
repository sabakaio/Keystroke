//
//  ActionLoader.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class ActionLoader: NSObject {
    fileprivate var actionsArray = [Action]()
    fileprivate(set) var numberOfSections = 1 // Read by ViewController
    var singleSectionMode = true // Read/Write by ViewController
    
    fileprivate struct SectionAttributes {
        var sectionOffset: Int  // the index of the first action of this section in the actions array
        var sectionLength: Int  // number of actions in the section
    }
    
    // sectionLengthArray - An array of randomly picked integers just for demo purposes.
    // sectionLengthArray[0] is 7, i.e. put the first 7 images from the imageFiles array into section 0
    // sectionLengthArray[1] is 5, i.e. put the next 5 images from the imageFiles array into section 1
    // and so on...
    fileprivate let sectionLengthArray = [5, 5]
    fileprivate var sectionsAttributesArray = [SectionAttributes]()
    
    
    func setupDataForActions(_ actions: [String]?) {
        
        if let actions = actions {
            createActionsForActions(actions)
        }
        
        if sectionsAttributesArray.count > 0 {  // If not first time, clean old sectionsAttributesArray
            sectionsAttributesArray.removeAll()
        }
        
        numberOfSections = 1
        
        if singleSectionMode {
            setupDataForSingleSectionMode()
        } else {
            setupDataForMultiSectionMode()
        }
    }
    
    fileprivate func setupDataForSingleSectionMode() {
        let sectionAttributes = SectionAttributes(sectionOffset: 0, sectionLength: actionsArray.count)
        sectionsAttributesArray.append(sectionAttributes) // sets up attributes for first section
    }
    
    fileprivate func setupDataForMultiSectionMode() {
        
        let haveOneSection = singleSectionMode || sectionLengthArray.count < 2 || actionsArray.count <= sectionLengthArray[0]
        var realSectionLength = haveOneSection ? actionsArray.count : sectionLengthArray[0]
        var sectionAttributes = SectionAttributes(sectionOffset: 0, sectionLength: realSectionLength)
        sectionsAttributesArray.append(sectionAttributes) // sets up attributes for first section
        
        guard !haveOneSection else {return}
        
        var offset: Int
        var nextOffset: Int
        let maxNumberOfSections = sectionLengthArray.count
        for i in 1..<maxNumberOfSections {
            numberOfSections += 1
            offset = sectionsAttributesArray[i-1].sectionOffset + sectionsAttributesArray[i-1].sectionLength
            nextOffset = offset + sectionLengthArray[i]
            if actionsArray.count <= nextOffset {
                realSectionLength = actionsArray.count - offset
                nextOffset = -1 // signal this is last section for this collection
            } else {
                realSectionLength = sectionLengthArray[i]
            }
            sectionAttributes = SectionAttributes(sectionOffset: offset, sectionLength: realSectionLength)
            sectionsAttributesArray.append(sectionAttributes)
            if nextOffset < 0 {
                break
            }
        }
    }
    
    fileprivate func createActionsForActions(_ actions: [String]) {
        if actionsArray.count > 0 {
            actionsArray.removeAll()
        }
        for action in actions {
            let actionItem = Action(binding: "X", description: action)
            actionsArray.append(actionItem)
        }
    }
    

    fileprivate func getActionsForApp(_ appName: String) -> [String]? {
        
        return ["Action one", "Action Two", "Action Three"]
        
//        let options: FileManager.DirectoryEnumerationOptions =
//            [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]
//        let fileManager = FileManager.default
//        let resourceValueKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey]
//        
//        guard let directoryEnumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: resourceValueKeys,
//                                                               options: options, errorHandler: { url, error in
//                                                                print("`directoryEnumerator` error: \(error).")
//                                                                return true
//        }) else { return nil }
//        
//        var urls: [URL] = []
//        for case let url as URL in directoryEnumerator {
//            do {
//                let resourceValues = try (url as NSURL).resourceValues(forKeys: resourceValueKeys)
//                guard let isRegularFileResourceValue = resourceValues[URLResourceKey.isRegularFileKey] as? NSNumber else { continue }
//                guard isRegularFileResourceValue.boolValue else { continue }
//                guard let fileType = resourceValues[URLResourceKey.typeIdentifierKey] as? String else { continue }
//                guard UTTypeConformsTo(fileType as CFString, "public.image" as CFString) else { continue }
//                urls.append(url)
//            }
//            catch {
//                print("Unexpected error occured: \(error).")
//            }
//        }
//        return urls
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return sectionsAttributesArray[section].sectionLength
    }
    
    func actionItemForIndexPath(_ indexPath: IndexPath) -> Action {
        let actionIndexInActionsArray = sectionsAttributesArray[indexPath.section].sectionOffset + indexPath.item
        let actionItem = actionsArray[actionIndexInActionsArray]
        return actionItem
    }
    
    func loadDataForAppWithName(_ appName: String) {
        let actions = getActionsForApp(appName)
        
        if actions != nil {
            print("\(actions?.count ?? 0) actions found for app \(appName)")
            for action in actions! {
                print("\(action)")
            }
        }
        setupDataForActions(actions)
    }
}
