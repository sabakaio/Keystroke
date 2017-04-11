//
//  KeyboardViewController.swift
//  Keystroke
//
//  Created by Arseny Zarechnev on 07/04/2017.
//  Copyright © 2017 Sabaka. All rights reserved.
//
//
//    ┌────────────────────────────────────────────────────────────────────────┐
//    │KeyboardView                                                            │
//    │ ┌────────────────────────────────────────────────────────────────────┐ │
//    │ │ContainerView                                                       │ │
//    │ │ ┌────────────────────────────────────────────────────────────────┐ │ │
//    │ │ │RowView                                                         │ │ │
//    │ │ │ ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐ │ │ │
//    │ │ │ │KeyContainerView  │ │KeyContainerView  │ │KeyContainerView  │ │ │ │
//    │ │ │ │   ┌─────────┐    │ │   ┌─────────┐    │ │   ┌─────────┐    │ │ │ │
//    │ │ │ │   │ KeyView │    │ │   │ KeyView │    │ │   │ KeyView │    │ │ │ │
//    │ │ │ │   └─────────┘    │ │   └─────────┘    │ │   └─────────┘    │ │ │ │
//    │ │ │ └──────────────────┘ └──────────────────┘ └──────────────────┘ │ │ │
//    │ │ └────────────────────────────────────────────────────────────────┘ │ │
//    │ │ ┌────────────────────────────────────────────────────────────────┐ │ │
//    │ │ │RowView                                                         │ │ │
//    │ │ └────────────────────────────────────────────────────────────────┘ │ │
//    │ │ ┌────────────────────────────────────────────────────────────────┐ │ │
//    │ │ │RowView                                                         │ │ │
//    │ │ └────────────────────────────────────────────────────────────────┘ │ │
//    │ └────────────────────────────────────────────────────────────────────┘ │
//    └────────────────────────────────────────────────────────────────────────┘
//

import Cocoa
import ReSwift
import PureLayout
import BonMot

let KEY_SIZE = NSSize(width: 45.0, height: 45.0)
let CONTAINER_VIEW_INSETS = EdgeInsets(top: 35.0, left: 10.0, bottom: 20.0, right: 10.0)
let KEY_FONT_SIZE: CGFloat = 20.0
let KEY_SPACING: CGFloat = 10.0
let KEY_TEXT_PADDING: CGFloat = 30.0
let KEY_BORDER_COLOR = NSColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)

public struct KeyStyles {
    let empty: StringStyle
    let plaintext: StringStyle
    let highlight: StringStyle
    let breadcrumbs: StringStyle
}

class ViewController: NSViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    @IBOutlet var keyboardView: NSView!
    
    private var rowViews: [RowView] = []
    private var keyContainerViews: [[KeyContainerView]] = [[], [], []]
    private var keyContainerTotalWidths: [CGFloat] = [0.0, 0.0, 0.0]
    private var keyFont: NSFont = NSFont(name: "San Francisco Display Light", size: KEY_FONT_SIZE)!
    private var breadcrumbsFont: NSFont = NSFont(name: "San Francisco Display Medium", size: 14.0)!
    private var containerView: NSView? = nil
    private var breadcrumbsView: NSTextField? = nil
    private var keyStyles: KeyStyles? = nil
    
    var keyRows: [[KeyboardKey]] = []
    
    private func configureKeyRows() {
        if keyRows.count > 0 {
            keyRows.removeAll()
        }

        keyRows = [
            [KeyCode.Key_q,
             KeyCode.Key_w,
             KeyCode.Key_e,
             KeyCode.Key_r,
             KeyCode.Key_t,
             KeyCode.Key_y,
             KeyCode.Key_u,
             KeyCode.Key_i,
             KeyCode.Key_o,
             KeyCode.Key_p].map({ keyCode in
                mainStore.state.keyboard.keys[keyCode]!
             }),
            [KeyCode.Key_a,
             KeyCode.Key_s,
             KeyCode.Key_d,
             KeyCode.Key_f,
             KeyCode.Key_g,
             KeyCode.Key_h,
             KeyCode.Key_j,
             KeyCode.Key_k,
             KeyCode.Key_l].map({ keyCode in
                mainStore.state.keyboard.keys[keyCode]!
             }),
            [KeyCode.Key_z,
             KeyCode.Key_x,
             KeyCode.Key_c,
             KeyCode.Key_v,
             KeyCode.Key_b,
             KeyCode.Key_n,
             KeyCode.Key_m].map({ keyCode in
                mainStore.state.keyboard.keys[keyCode]!
             })
        ]
    }
    
    private func setupKeyStyles() {
        let theme = mainStore.state.theme.theme

        let plaintext = StringStyle(
            .alignment(.center),
            .font(keyFont),
            .color(theme.folderColor.asNSColor())
        )
        
        let highlight = plaintext.byAdding(
            .color(theme.operationColor.asNSColor())
        )
        
        let empty = plaintext.byAdding(
            .color(theme.emptyColor.asNSColor())
        )
        
        let breadcrumbs = empty.byAdding(
            .alignment(.left),
            .font(breadcrumbsFont),
            .lineSpacing(15.0)
        )
        
        keyStyles = KeyStyles(empty: empty, plaintext: plaintext, highlight: highlight, breadcrumbs: breadcrumbs)
    }

    private func setupKeyboardView() {
        setupKeyStyles()

        self.containerView = NSView.newAutoLayout()
        let container = self.containerView!
        keyboardView.addSubview(container)
        
        container.autoAlignAxis(.vertical, toSameAxisOf: view)
        container.autoPinEdgesToSuperviewEdges(with: CONTAINER_VIEW_INSETS)
        
        for (rowIndex, row) in keyRows.enumerated() {
            // First create row view
            let rowView: RowView
            if rowIndex < 1 {
                rowView = RowView.createFirstRow(in: container)
            } else {
                rowView = RowView.createNextRow(in: container, after: rowViews[rowIndex - 1])
            }

            rowViews.append(rowView)
            
            // Then create views for keys in the row
            for (keyIndex, key) in row.enumerated() {
                let keyContainerView = KeyContainerView.create(
                    in: rowView,
                    after: keyIndex >= 1 ? keyContainerViews[rowIndex][keyIndex - 1] : nil // keyIndex < keyRows[rowIndex].count
                )
                
                let keyView = KeyView.create(
                    in: keyContainerView,
                    for: key,
                    using: keyStyles!
                )
                keyContainerViews[rowIndex].append(keyContainerView)
                
                let textSize = keyView.attributedStringValue.size()
                let keyWidthWithPadding = max(textSize.width + KEY_TEXT_PADDING, KEY_SIZE.width)
                keyContainerView.setOrUpdateWidthDimension(keyWidthWithPadding)
                keyContainerTotalWidths[rowIndex] = keyContainerTotalWidths[rowIndex] + keyWidthWithPadding
            }
            
            let rowWidth = keyContainerTotalWidths[rowIndex] + (CGFloat(keyContainerViews[rowIndex].count - 1) * KEY_SPACING)
            let firstKeyViewInRow = keyContainerViews[rowIndex].first!
            
            firstKeyViewInRow.setOrUpdatePinForCentering(withInset: (WINDOW_SIZE.width - CONTAINER_VIEW_INSETS.left - CONTAINER_VIEW_INSETS.right - rowWidth) / 2)
        }
    }
    
    private func updateKeyboardView() {
        // Setup flow layout
        keyContainerTotalWidths = [0.0, 0.0, 0.0]
        
        for (rowIndex, row) in keyRows.enumerated() {
            for (keyIndex, key) in row.enumerated() {
                let keyContainerView = keyContainerViews[rowIndex][keyIndex]
                let keyView = keyContainerView.subviews[0] as! KeyView
                
                keyView.setStringValue(for: key, using: keyStyles!)
                
                let textSize = keyView.attributedStringValue.size()
                let keyWidthWithPadding = max(textSize.width + KEY_TEXT_PADDING, KEY_SIZE.width)
                keyContainerView.setOrUpdateWidthDimension(keyWidthWithPadding)
                keyContainerTotalWidths[rowIndex] = keyContainerTotalWidths[rowIndex] + keyWidthWithPadding
            }
            
            let rowWidth = keyContainerTotalWidths[rowIndex] + (CGFloat(keyContainerViews[rowIndex].count - 1) * KEY_SPACING)
            let firstKeyViewInRow = keyContainerViews[rowIndex][0]
            firstKeyViewInRow.setOrUpdatePinForCentering(withInset: (WINDOW_SIZE.width - CONTAINER_VIEW_INSETS.left - CONTAINER_VIEW_INSETS.right - rowWidth) / 2)
        }
    }
    
    private func setupBreadcrumbsView() {
        let appName = mainStore.state.keyboard.appName ?? ""
        breadcrumbsView = NSTextField(labelWithAttributedString: appName.styled(with: keyStyles!.breadcrumbs))
        let breadcrumbs = breadcrumbsView!
        keyboardView.addSubview(breadcrumbs)
        breadcrumbs.autoPinEdge(toSuperviewEdge: .top, withInset: 8.0)
        breadcrumbs.autoPinEdge(.bottom, to: .top, of: containerView!, withOffset: 10.0)
        breadcrumbs.autoPinEdge(.left, to: .left, of: keyContainerViews.first!.first!)
        breadcrumbs.autoPinEdge(.right, to: .right, of: keyContainerViews.first!.last!)
    }
    
    private func updateBreadcrumbsView() {
        let appName = mainStore.state.keyboard.appName ?? ""
        breadcrumbsView!.attributedStringValue = appName.styled(with: keyStyles!.breadcrumbs)
    }
    
    func activateTheme(theme: Theme) {
        guard let layer = view.layer else { return }
        layer.backgroundColor = NSColor.init(
            calibratedRed: theme.backgroundColor.calibratedRed,
            green: theme.backgroundColor.green,
            blue: theme.backgroundColor.blue,
            alpha: theme.backgroundColor.alpha
            ).cgColor;
    }
    
    func newState(state: AppState) {
        self.activateTheme(theme: state.theme.theme)
        
        configureKeyRows()
        updateKeyboardView()
        updateBreadcrumbsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureKeyRows()
        setupKeyboardView()
        setupBreadcrumbsView()

        mainStore.subscribe(self)
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.gray.cgColor
        view.layer?.cornerRadius = 10
    }
}
