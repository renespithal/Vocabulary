//
//  CoursesController.swift
//  Vocabulary
//
//  Created by Rene Nespithal on 20.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import TBEmptyDataSet
import RealmSwift
import Localize_Swift

class CoursesController: StyleableTableViewController {
    
    
    var user : User!
    var userResults : Results<User>!
    var userToken : NotificationToken!
    var languageToken : NotificationToken!
    var languages: List<Language>?
    var language : Language!
    var collection : Collection!
    
    // MARK: - Initialization
    
    init() {
        super.init(style: .plain)
        restorationIdentifier = String(describing: type(of: self))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewSetup()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.language = language
        appDelegate.collections = language.collections
        appDelegate.collection = nil
        appDelegate.word = nil
    }
    
    override func viewSetup() {
            super.viewSetup()
            self.navigationItem.title = "Courses".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if indexPath.row == 0 {
            let collection = Collection()
            collection.name = "German - English"
            collection.comment = nil
            
            RealmHelper.sharedInstance.realm.beginWrite()
            RealmHelper.sharedInstance.realm.add(collection)
            language.collections.append(collection)
            try! RealmHelper.sharedInstance.realm.commitWrite()
            
            let result = NSArray(contentsOf: Bundle.main.url(forResource:"gerEng", withExtension: "plist")!)
                for case let dictionary as Dictionary<String,Any> in result! {
                    print(dictionary)
                    
                    RealmHelper.sharedInstance.createWord(name: dictionary["name"]! as! String, translation: dictionary["translation"]! as! String, comment: nil, keywords: nil, language: language!, collection: collection)
            }
            
            self.navigationController?.popViewController(animated: true)

        
        }
        
        if indexPath.row == 1 {
            
            let collection = Collection()
            collection.name = "English - German"
            collection.comment = nil
            
            RealmHelper.sharedInstance.realm.beginWrite()
            RealmHelper.sharedInstance.realm.add(collection)
            language.collections.append(collection)
            try! RealmHelper.sharedInstance.realm.commitWrite()
            
            let result = NSArray(contentsOf: Bundle.main.url(forResource:"engGer", withExtension: "plist")!)
            for case let dictionary as Dictionary<String,Any> in result! {
                print(dictionary)
                
                RealmHelper.sharedInstance.createWord(name: dictionary["name"]! as! String, translation: dictionary["translation"]! as! String, comment: nil, keywords: nil, language: language!, collection: collection)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
            cell.textLabel?.text = "German - English"
            cell.imageView?.image = UIImage(named: "list")
            cell.showsReorderControl = true
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
            cell.textLabel?.text = "English - German"
            cell.imageView?.image = UIImage(named: "list")
            cell.editingAccessoryType = .detailButton
            return cell
        }
        
    }
    

}
