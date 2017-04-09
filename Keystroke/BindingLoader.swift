//
//  BindingLoader.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class BindingLoader: NSObject {
    fileprivate var bindingSet = [Binding]()
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
    
    
    func setupDataForBindings(_ bindings: [String]?) {
        
        if let bindings = bindings {
            createBindingSetForBindings(bindings)
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
        let sectionAttributes = SectionAttributes(sectionOffset: 0, sectionLength: bindingSet.count)
        sectionsAttributesArray.append(sectionAttributes) // sets up attributes for first section
    }
    
    fileprivate func setupDataForMultiSectionMode() {
        
        let haveOneSection = singleSectionMode || sectionLengthArray.count < 2 || bindingSet.count <= sectionLengthArray[0]
        var realSectionLength = haveOneSection ? bindingSet.count : sectionLengthArray[0]
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
            if bindingSet.count <= nextOffset {
                realSectionLength = bindingSet.count - offset
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
    
    fileprivate func createBindingSetForBindings(_ bindings: [String]) {
        if bindingSet.count > 0 {
            bindingSet.removeAll()
        }
        for bindingString in bindings {
            let binding = Binding(binding: "X", description: bindingString)
            bindingSet.append(binding)
        }
    }
    

    fileprivate func getBindingsForApp(_ appName: String) -> [String]? {
        if (appName == "iTerm2") {
          return ["S - Split Horizontally", "V - Split Vertically"]
        }
        return ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return sectionsAttributesArray[section].sectionLength
    }
    
    func bindingForIndexPath(_ indexPath: IndexPath) -> Binding {
        let bindingIndexInBindingSet = sectionsAttributesArray[indexPath.section].sectionOffset + indexPath.item
        let binding = bindingSet[bindingIndexInBindingSet]
        return binding
    }
    
    func loadDataForAppWithName(_ appName: String) {
        let bindings = getBindingsForApp(appName)
        
//        if bindings != nil {
//            print("\(bindings?.count ?? 0) actions found for app \(appName)")
//            for binding in bindings! {
//                print("\(binding)")
//            }
//        }
        setupDataForBindings(bindings)
    }
}
