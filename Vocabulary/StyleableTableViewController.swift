//
//  StyleableTableViewController.swift
//  Vocabulary
//
//  Created by Alex on 19/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import TBEmptyDataSet
import Presentr
import RealmSwift
import Localize_Swift

class StyleableTableViewController: UITableViewController, TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {

    let presenter: Presentr = {
        let customPresenter = Presentr(presentationType: .dynamic(center:.center))
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = true
        customPresenter.dismissOnSwipeDirection = .top
        customPresenter.presentationType = .custom(width: .custom(size: 300), height: .custom(size: 300), center: .topCenter)
        return customPresenter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apply(currentStyle)
    }
    
    func viewSetup() {
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "navigationbar-back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "navigationbar-back")
        
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false;
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let archiveCell = cell as? Cell else {
            return
        }
        
        archiveCell.apply(style: currentStyle.cellStyle)
    }
    
    // MARK: - Applying styles
    
    private struct Style {
        let backgroundColor: UIColor
        let separatorColor: UIColor?
        let cellStyle: Cell.Style
        
        static let light = Style(
            backgroundColor: tableViewCellBackgroundColor,
            separatorColor: tableViewSeparatorColor,
            cellStyle: .light
        )
        
        static let dark = Style(
            backgroundColor: tableViewCellBackgroundColorDark,
            separatorColor: tableViewSeparatorColorDark,
            cellStyle: .dark
        )
    }
    
    private var currentStyle: Style {
        return useDarkMode ? .dark : .light
    }
    
    fileprivate var useDarkMode = false {
        didSet { apply(currentStyle) }
    }
    
    private func apply(_ style: Style) {
        tableView.backgroundColor = style.backgroundColor
        tableView.separatorColor = style.separatorColor
        //apply(style.cellStyle, toCells: tableView.visibleCells)
    }
    
    private func apply(_ cellStyle: Cell.Style, toCells cells: [UITableViewCell]) {
        for cell in cells {
            guard let archiveCell = cell as? Cell else {
                continue
            }
            archiveCell.apply(style: cellStyle)
        }
    }
    
    // MARK: - TBEmptyDataSet
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return nil
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Words".localized())
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Press '+' to add your first word".localized())
    }
    
    func backgroundColorForEmptyDataSet(in scrollView: UIScrollView) -> UIColor? {
        // return the backgroundColor for EmptyDataSet
        return nil
    }
    
    func verticalOffsetForEmptyDataSet(in scrollView: UIScrollView) -> CGFloat {
        // return the vertical offset for EmptyDataSet, default is 0
        return -44
    }
    
    func verticalSpacesForEmptyDataSet(in scrollView: UIScrollView) -> [CGFloat] {
        // return the vertical spaces from top to bottom for EmptyDataSet, default is [12, 12]
        return [12, 12]
    }
    
    // MARK: - TBEmptyDataSet
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetTapEnabled(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetScrollEnabled(in scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func emptyDataSetDidTapEmptyView(in scrollView: UIScrollView) {
        // do something
    }
    
    func emptyDataSetWillAppear(in scrollView: UIScrollView) {
        // do something
    }
    
    func emptyDataSetDidAppear(in scrollView: UIScrollView) {
        // do something
    }
    
    func emptyDataSetWillDisappear(in scrollView: UIScrollView) {
        // do something
    }
    
    func emptyDataSetDidDisappear(in scrollView: UIScrollView) {
        // do something
    }
    
}


extension StyleableTableViewController: GagatStyleable {
    
    func toggleActiveStyle() {
        useDarkMode = !useDarkMode
    }
    
}
