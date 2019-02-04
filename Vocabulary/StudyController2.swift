//
//  StudyController2.swift
//  Vocabulary
//
//  Created by Margaretha Lucha on 18.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//



import UIKit
import UserNotifications
import RealmSwift
import Localize_Swift
import SwipeCellKit

class StudyController2: StyleableTableViewController, SwipeTableViewCellDelegate, UIViewControllerRestoration, UIDataSourceModelAssociation, UNUserNotificationCenterDelegate {
    
    var user : User!
    var userResults : Results<User>!
    var userToken : NotificationToken!
    var languageToken : NotificationToken!
    var languages: List<Language>?
    var language : Language?
    var collection: Collection?
    var collections: List<Collection>?
   
    
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
        appDelegate.language = nil
        appDelegate.collections = nil
        appDelegate.collection = nil
        appDelegate.word = nil
    }
    
    
    
    override func viewSetup() {
        super.viewSetup()
        
        self.navigationItem.title = "Vocabulary Trainer"
        
        tableView.register(WordCell.self, forCellReuseIdentifier: "WordCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Cancel".localized(), style: .done, target: self, action: #selector(cancel))
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .white
    }
    
    func cancel(){
        
        self.dismiss(animated: true, completion: nil)
        
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
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.languages = self?.user.languages
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.user = user
        appDelegate.languages = user.languages
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
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell") as! WordCell
        let language = user.languages[indexPath.row]
        cell.delegate = self
        
        cell.textLabel?.text = GeneralHelper.sharedInstance.languageForCode(code: language.fromLanguage) + " - " + GeneralHelper.sharedInstance.languageForCode(code: language.toLanguage)
        
        if(language.collections.count == 1){
            cell.detailTextLabel?.text = String(format: "%d List".localized(), language.collections.count)
        } else {
            cell.detailTextLabel?.text = String(format: "%d Lists".localized(), language.collections.count)
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
        if section == 0 {
            return "Swipe and select your desired list"
        }
        return nil
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
    
  
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let selectAllAction = SwipeAction(style: .`default`, title: "All Words".localized()){ action in
            let cardVC = CardViewController()
            //All Words selected
            cardVC.selector = 1
            cardVC.language = self.user.languages[indexPath.row]
            self.present(StyleableNavigationController.init(rootViewController: cardVC), animated: true, completion: nil)

        }
       
        selectAllAction.backgroundColor = highlightColor0
        
        let selectFavoritesAction = SwipeAction(style: .`default`, title: "Favorites".localized()){ action in
            let cardVC = CardViewController()
            cardVC.language = self.user.languages[indexPath.row]
            //Favorites selected
            cardVC.selector = 2
            self.present(StyleableNavigationController.init(rootViewController: cardVC), animated: true, completion: nil)
            
        }
        selectFavoritesAction.backgroundColor = highlightColor2
        
        let selectListsAction = SwipeAction(style: .`default`, title: "Lists".localized()){ action, indexPath in
            let listVC = StudyListController()
            listVC.language = self.user.languages[indexPath.row]
            self.navigationController?.pushViewController(listVC, animated: true)
            
        }
        selectListsAction.backgroundColor = highlightColor3
        
        return [selectListsAction,selectFavoritesAction,selectAllAction]
    }
    

    
    override func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Languages".localized())
    }
    
    override func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "")
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
