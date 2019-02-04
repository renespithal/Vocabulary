//
//  LanguageController.swift
//  Vocabulary
//
//  Created by Alex on 24.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift
import Localize_Swift
import SwipeCellKit

class LanguageController: StyleableTableViewController, SwipeTableViewCellDelegate, UIViewControllerRestoration, UIDataSourceModelAssociation, UNUserNotificationCenterDelegate {
    var user : User!
    var userResults : Results<User>!
    var userToken : NotificationToken!
    var languageToken : NotificationToken!

    
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
        setEditButton()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.language = nil
        appDelegate.collections = nil
        appDelegate.collection = nil
        appDelegate.word = nil
    }
    
    deinit {
        userToken.stop()
        languageToken.stop()
    }
    
    
    override func viewSetup() {
        super.viewSetup()
        
        self.navigationItem.title = "Languages".localized()
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .white
    }
        
     func realmSetup() {
        userResults = RealmHelper.sharedInstance.realm.objects(User.self)
        if userResults!.count > 0 {
            user = userResults![0]
        }
        
        userToken = userResults.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            if (self?.userResults.count)! > 0 {
                self?.user = self?.userResults[0]
            }
        }

        languageToken = user.languages.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.updateLanguages(changes: changes)
            self?.setEditButton()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.languages = self?.user.languages
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.user = user
        appDelegate.languages = user.languages
     }
    
    func setEditButton() {
        if user.languages.count == 0 {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = editButtonItem
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.languages.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        let language = user.languages[indexPath.row]
        cell.delegate = self
        
        cell.textLabel?.text = GeneralHelper.sharedInstance.languageForCode(code: language.fromLanguage) + " - " + GeneralHelper.sharedInstance.languageForCode(code: language.toLanguage)
        
        if(language.words.count == 1){
            cell.detailTextLabel?.text = String(format: "%d Word".localized(), language.words.count)
        } else {
            cell.detailTextLabel?.text = String(format: "%d Words".localized(), language.words.count)
        }
        
        cell.imageView?.image = GeneralHelper.sharedInstance.imageForDictionary(code1: language.fromLanguage, code2: language.toLanguage)
        cell.editingAccessoryType = .none
        cell.showsReorderControl = true

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCollection(language: user.languages[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            RealmHelper.sharedInstance.realm.beginWrite()
            let language = user.languages[indexPath.row]
            for collection in language.collections {
                for word in collection.words {
                    RealmHelper.sharedInstance.realm.delete(word)
                }
            }
            
            for course in language.courses {
                for collection in course.collections {
                    for word in collection.words {
                        RealmHelper.sharedInstance.realm.delete(word)
                    }
                }
            }

            RealmHelper.sharedInstance.realm.delete(language.collections)
            RealmHelper.sharedInstance.realm.delete(language.courses)
            RealmHelper.sharedInstance.realm.delete(language)
            try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [languageToken, userToken])
            if tableView.numberOfRows(inSection: 0) > 1 {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                tableView.reloadData()
                setEditButton()
            }
        }
    }
    

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath;
        }
        return proposedDestinationIndexPath;
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        RealmHelper.sharedInstance.realm.beginWrite()
        user.languages.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [languageToken, userToken])
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }        
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete".localized()) { action, indexPath in
            RealmHelper.sharedInstance.realm.beginWrite()
            let language = self.user.languages[indexPath.row]
            for collection in language.collections {
                for word in collection.words {
                    RealmHelper.sharedInstance.realm.delete(word)
                }
            }
            
            for course in language.courses {
                for collection in course.collections {
                    for word in collection.words {
                        RealmHelper.sharedInstance.realm.delete(word)
                    }
                }
            }
            
            RealmHelper.sharedInstance.realm.delete(language.collections)
            RealmHelper.sharedInstance.realm.delete(language.courses)
            RealmHelper.sharedInstance.realm.delete(language)
            try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [self.languageToken, self.userToken])
            if tableView.numberOfRows(inSection: 0) > 1 {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                tableView.reloadData()
                self.setEditButton()
            }
        }
        deleteAction.backgroundColor = pinkColor


        
        return [deleteAction]
    }
    
    func showCollection(language: Language) {
        let collectionController = CollectionController()
        collectionController.language = language
        self.navigationController?.pushViewController(collectionController, animated: true)
    }
    
    
    override func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Languages".localized())
    }
    
    override func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Press '+' to add a language".localized())
    }
    
    override func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named:"empty-dataset-language")
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
    
    func updateLanguages<T>(changes: RealmCollectionChange<T>) {
        switch changes {
        case .update(_, let deletions, let insertions, let updates):
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: insertions.map {IndexPath(row: $0, section: 0)}, with: .automatic)
            self.tableView.reloadRows(at: updates.map {IndexPath(row: $0, section: 0)}, with: .automatic)
            self.tableView.deleteRows(at: deletions.map {IndexPath(row: $0, section: 0)}, with: .automatic)
            self.tableView.endUpdates()
            
        default: break
        }
    }
}
