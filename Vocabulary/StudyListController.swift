//
//  StudyListController.swift
//  Vocabulary
//
//  Created by Rene Nespithal on 20.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift
import Localize_Swift
import SwipeCellKit

class StudyListController: StyleableTableViewController, UIViewControllerRestoration, UIDataSourceModelAssociation, UNUserNotificationCenterDelegate  {
    var language : Language!
    var collectionsToken : NotificationToken!
    var coursesToken : NotificationToken!
    var allWordsToken : NotificationToken!
    var favoritesToken : NotificationToken!
    
    // MARK: - Initialization
    
    init() {
        super.init(style: .grouped)
        restorationIdentifier = String(describing: type(of: self))
        restorationClass = type(of: self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle and actions
    override func viewDidLoad() {
        super.viewDidLoad()
        realmSetup()
        viewSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.language = language
        appDelegate.collections = language.collections
        appDelegate.collection = nil
        appDelegate.word = nil
    }
    
    deinit {
        allWordsToken.stop()
        favoritesToken.stop()
        coursesToken.stop()
        collectionsToken.stop()
    }
    
    
    override func viewSetup() {
        super.viewSetup()
        
        self.navigationItem.title = GeneralHelper.sharedInstance.languageForCode(code: language.fromLanguage) + " - " + GeneralHelper.sharedInstance.languageForCode(code: language.toLanguage)
        
        tableView.separatorColor = .white
    }
    
    func realmSetup() {
        allWordsToken = language.words.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.updateAllWords(changes: changes)
        }
        
        favoritesToken = language.favorites.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.updateFavorites(changes: changes)
        }
        
        coursesToken = language.courses.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.updateCourses(changes: changes)
        }
        
        collectionsToken = language.collections.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.updateLists(changes: changes)
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.collections = self?.language.collections
        }
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return language.collections.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        let collection = language.collections[indexPath.row]
        cell.textLabel?.text = collection.name
        //cell.detailTextLabel?.text = String(format: "%d Words".localized(), collection.words.count)
        if(collection.words.count == 1){
            cell.detailTextLabel?.text = String(format: "%d Word".localized(), collection.words.count)
        } else {
            cell.detailTextLabel?.text = String(format: "%d Words".localized(), collection.words.count)
        }

        cell.imageView?.image = UIImage(named: "list")
        cell.editingAccessoryType = .detailButton
        cell.showsReorderControl = true
        return cell
        
    }
    
    /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Lists".localized()
        }
        return nil
    }*/
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Select your List".localized()
        
        }
        return nil
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            //showList(collection: language.collections[indexPath.row])
                let cardVC = CardViewController()
                cardVC.collection = language.collections[indexPath.row]
                //favo selected
                cardVC.selector = 3
                self.present(StyleableNavigationController.init(rootViewController: cardVC), animated: true, completion: nil)
            
        }
        
    }
    
    /*override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        let collection = language.collections[indexPath.row]
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.collection = collection
        appDelegate.editCollection()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
            return false
        }
        return true
    }*/
    
    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 1 {
                RealmHelper.sharedInstance.realm.beginWrite()
                RealmHelper.sharedInstance.realm.delete(language.courses[indexPath.row - 1])
                try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [coursesToken])
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if tableView.numberOfRows(inSection: 1) > 1 {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    tableView.reloadData()
                }
            } else if indexPath.section == 2 {
                RealmHelper.sharedInstance.realm.beginWrite()
                RealmHelper.sharedInstance.realm.delete(language.collections[indexPath.row])
                try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [collectionsToken])
                if tableView.numberOfRows(inSection: 2) > 1 {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    tableView.reloadData()
                }
            }
        }
    }*/
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 1 {
            RealmHelper.sharedInstance.realm.beginWrite()
            language.courses.move(from: sourceIndexPath.row - 1, to: destinationIndexPath.row - 1)
            try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [coursesToken])
        } else if sourceIndexPath.section == 2 {
            RealmHelper.sharedInstance.realm.beginWrite()
            language.collections.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
            try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [collectionsToken])
        }
    }
    
    
   
    
    public static func viewController(withRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController?{
        return UIViewController()
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        guard isViewLoaded else {
            /*
             If the view has not been loaded, the app will crash
             upon accessing force-unwrapped outlets, e.g., `slider`.
             */
            return
        }
        
        //coder.encode(slider.value, forKey: encodingKeySliderValue)
    }
    override func decodeRestorableState(with coder: NSCoder)  {
        super.decodeRestorableState(with: coder)
        assert(isViewLoaded, "We assume the controller is never restored without loading its view first.")
        //slider.value = coder.decodeFloat(forKey: encodingKeySliderValue)
    }
    override func applicationFinishedRestoringState() {
        print("finished restoring")
    }
    
    /*  override func encodeRestorableStatewithWithCoder(_ coder: NSCoder) {
     // Save all the data, that you need for restoring. For instance, i need to save only one number.
     if let someNumberYouNeedForRestoring = number {
     coder.encodeInteger(someNumberYouNeedForRestoring, forKey: "number")
     }
     // It's important to call `super` because `UIKit` does a great part of restoration job for you
     super.encodeRestorableStateWithCoder(coder)
     }
     
     override func decodeRestorableState(with coder: NSCoder) {
     someNumberYouNeedForRestoring = coder.decodeIntegerForKey("number")
     super.decodeRestorableStateWithCoder(coder)
     }
     
     override func applicationFinishedRestoringState() {
     // Final configuration goes here.
     // Load images, reload data, e. t. c.
     }
     
     static func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject],
     coder: NSCoder) -> UIViewController? {
     let viewController = YourNeededViewController()
     return viewController
     }*/
    
    
    // MARK: - UIDataSourceModelAssociation
    
    public func modelIdentifierForElement(at idx: IndexPath, in view: UIView) -> String?{
        return ""
    }
    
    public func indexPathForElement(withModelIdentifier identifier: String, in view: UIView) -> IndexPath?{
        return IndexPath(row: 0, section: 0)
    }
    
    func updateAllWords<T>(changes: RealmCollectionChange<T>) {
        switch changes {
        case .update(_, let deletions, let insertions, _):
            if deletions.count > 0 || insertions.count > 0 {
                self.tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                self.tableView.endUpdates()
            }
        default: break
        }
    }
    
    func updateFavorites<T>(changes: RealmCollectionChange<T>) {
        switch changes {
        case .update(_, let deletions, let insertions, _):
            if deletions.count > 0 || insertions.count > 0 {
                self.tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                self.tableView.endUpdates()
            }
        default: break
        }
    }
    
    func updateCourses<T>(changes: RealmCollectionChange<T>) {
        switch changes {
        case .update(_, let deletions, let insertions, let updates):
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: insertions.map {IndexPath(row: $0, section: 1)}, with: .automatic)
            self.tableView.reloadRows(at: updates.map {IndexPath(row: $0, section: 1)}, with: .automatic)
            self.tableView.deleteRows(at: deletions.map {IndexPath(row: $0, section: 1)}, with: .automatic)
            self.tableView.endUpdates()
            
        default: break
        }
    }
    
    func updateLists<T>(changes: RealmCollectionChange<T>) {
        
        switch changes {
        case .update(_, let deletions, let insertions, let updates):
            print("updates \(updates)")
            print("insertions \(insertions)")
            
            self.tableView.beginUpdates()
            if tableView.numberOfSections == 2 {
                tableView.insertSections(IndexSet([2]), with: .automatic)
            }
            self.tableView.insertRows(at: insertions.map {IndexPath(row: $0, section: 2)}, with: .automatic)
            self.tableView.reloadRows(at: updates.map {IndexPath(row: $0, section: 2)}, with: .automatic)
            self.tableView.deleteRows(at: deletions.map {IndexPath(row: $0, section: 2)}, with: .automatic)
            self.tableView.endUpdates()
            
        default: break
        }
    }
}

