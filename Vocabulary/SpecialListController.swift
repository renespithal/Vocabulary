//
//  SpecialListController.swift
//  Vocabulary
//
//  Created by Alex on 30.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class SpecialListController: StyleableTableViewController, SwipeTableViewCellDelegate, UIViewControllerRestoration, UIDataSourceModelAssociation {
    var words: List<Word>!
    var wordsToken : NotificationToken!
    var favorites: List<Word>!
    var viewTitle : String?
    
    // MARK: - Initialization
    
    convenience init(_ words: List<Word>, favorites : List<Word>, viewTitle : String) {
        self.init()
        self.words = words
        self.favorites = favorites
        self.viewTitle = viewTitle
    }
    
    init() {
        super.init(style: .plain)
        restorationIdentifier = String(describing: type(of: self))
        restorationClass = type(of: self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    deinit {
        wordsToken.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realmSetup()
        viewSetup()
        setEditButton()
    }
    
    override func viewSetup() {
        super.viewSetup()
        
        self.title = viewTitle
        
        tableView.register(WordCell.self, forCellReuseIdentifier: "WordCell")
        tableView.tableFooterView = UIView()
    }
    
    func realmSetup() {
        wordsToken = words.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.updateWords(changes: changes)
            self?.setEditButton()
        }
    }
    
    
    func setEditButton() {
        if words.count == 0 {
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
        return words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell") as! WordCell
        cell.delegate = self
        let word = words[indexPath.row]
        
        cell.nameLabel.text = word.name
        cell.translationLabel.text = word.translation
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            RealmHelper.sharedInstance.realm.beginWrite()
            RealmHelper.sharedInstance.realm.delete(words[indexPath.row])
            try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [wordsToken])
            if tableView.numberOfRows(inSection: 0) > 1 {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                tableView.reloadData()
                setEditButton()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let word = words[indexPath.row]
        
        let editAction = SwipeAction(style: .`default`, title: "Edit".localized()) { action, indexPath in
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.word = word
            appDelegate.editWord()
        }
        editAction.backgroundColor = highlightColor2
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete".localized()) { action, indexPath in
            RealmHelper.sharedInstance.realm.beginWrite()
            RealmHelper.sharedInstance.realm.delete(self.words[indexPath.row])
            try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [self.wordsToken])
            if tableView.numberOfRows(inSection: 0) > 1 {
                tableView.deleteRows(at: [indexPath], with: .left)
            } else {
                tableView.reloadData()
                self.setEditButton()
            }
        }
        deleteAction.backgroundColor = highlightColor3
        
        
        let favoriteTitle = word.isFavorite ? "Unfave".localized() : "Fave".localized()
        
        let favoriteAction = SwipeAction(style: .`default`, title: favoriteTitle) { action, indexPath in
            try! RealmHelper.sharedInstance.realm.write {
                if word.isFavorite {
                    self.favorites.remove(objectAtIndex: self.favorites.index(of: word)!)
                } else {
                    self.favorites.append(word)
                }
                word.isFavorite = !word.isFavorite
            }
        }
        
        favoriteAction.backgroundColor = highlightColor1
        
        
        let shareAction = SwipeAction(style: .`default`, title: "Share".localized()) { action, indexPath in
            let objectsToShare = [word.name + " " + word.translation] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
        shareAction.backgroundColor = highlightColor0
        
        return [deleteAction, editAction, favoriteAction, shareAction]
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        RealmHelper.sharedInstance.realm.beginWrite()
        words.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [wordsToken])
    }
        
      
    override func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Words".localized())
    }
    
    override func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Press '+' to add a word".localized())
    }
    
    override func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named:"empty-dataset-word")
    }
    
    // MARK: - State Restoration
    
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
    
    func updateWords<T>(changes: RealmCollectionChange<T>) {
        switch changes {
        case .update(_, let deletions, let insertions, let updates):
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: insertions.map {IndexPath(row: $0, section: 0)}, with: .top)
            self.tableView.reloadRows(at: updates.map {IndexPath(row: $0, section: 0)}, with: .automatic)
            self.tableView.deleteRows(at: deletions.map {IndexPath(row: $0, section: 0)}, with: .automatic)
            self.tableView.endUpdates()
            
        default: break
        }
    }
}


