//
//  ViewController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    let actionLoader = ActionLoader()

    private func configureCollectionView() {

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 40.0)
        flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout

        // For optimal performance, NSCollectionView is designed to be layer-backed.
        view.wantsLayer = true
        
        // Transparent background
        collectionView.layer?.backgroundColor = NSColor.red.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        actionLoader.loadDataForAppWithName("test")
        configureCollectionView()
    }
    
    func loadDataForAppWithName(_ appName: String) {
        actionLoader.loadDataForAppWithName(appName)
        collectionView.reloadData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController : NSCollectionViewDataSource {
    
    // Can be omitted for single section
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return actionLoader.numberOfSections
    }
    
    // This is one of two required methods for NSCollectionViewDataSource.
    // Here you return the number of items in the section specified by the section parameter.
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionLoader.numberOfItemsInSection(section)
    }
    
    // This is the second required method. It returns a collection view item for a given indexPath.
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else {return item}
        
        let action = actionLoader.actionItemForIndexPath(indexPath)

        collectionViewItem.actionText = "\(action.bindingKey) - \(action.descriptionText)"
        return item
    }
    
}
