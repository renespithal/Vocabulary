//
//  AddLanguageController.swift
//  Vocabulary
//
//  Created by Alex on 18/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift

class ToLanguageController: StyleableTableViewController {
    var user : User?
    var userLanguages = GeneralHelper.sharedInstance.userLanguages
    var popularLanguages = GeneralHelper.sharedInstance.popularLanguages()
    public var modalPresentation = false
    
    public var usernameTLC: String = ""
    public var emailTLC: String = ""


    init() {
        super.init(style: .grouped)
        restorationIdentifier = String(describing: type(of: self))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewSetup() {
        super.viewSetup()
        tableView.rowHeight = 60
        title = "Which language would you like to learn?".localized()
        
        navigationItem.hidesBackButton = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LanguageCell")
        tableView.tableFooterView = UIView()
        
        tableView.separatorColor = .lightGray
        
        if modalPresentation {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        }
    }
    
    
    func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userLanguages.count
        } else if section == 1 {
            return popularLanguages.count
        }
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "More".localized()
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "If your desired language is not in this list, you can add your own custom language.".localized()
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0  {
            return CGFloat.leastNonzeroMagnitude
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell")
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = GeneralHelper.sharedInstance.languageForCode(code: userLanguages[indexPath.row])
            cell?.imageView?.image = GeneralHelper.sharedInstance.flagForLanguageCode(code: userLanguages[indexPath.row])
        } else if indexPath.section == 1 {
            cell?.textLabel?.text = GeneralHelper.sharedInstance.languageForCode(code: popularLanguages[indexPath.row])
            cell?.imageView?.image = GeneralHelper.sharedInstance.flagForLanguageCode(code: popularLanguages[indexPath.row])
        } else {
            if indexPath.row == 0 {
                cell?.textLabel?.text = "Other Languages".localized()
                cell?.imageView?.image = UIImage(named: "flag-other")
            } else {
                cell?.textLabel?.text = "Custom Language".localized()
                cell?.imageView?.image = UIImage(named: "flag-custom")
            }
        }
        cell?.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell?.accessoryType = .disclosureIndicator
        
        return cell!
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            showSelectToLanguageController(languageCode: userLanguages[indexPath.row])
        } else if indexPath.section == 1 {
            showSelectToLanguageController(languageCode: popularLanguages[indexPath.row])
        } else {
            if indexPath.row == 0 {
                
            } else {
                
            }
        }
    }
    
    func showSelectToLanguageController(languageCode: String){
        let toLanguageController = FromLanguageController()
        toLanguageController.user = user
        toLanguageController.toLanguageCode = languageCode
        toLanguageController.modalPresentation = modalPresentation
        toLanguageController.nameFLC = self.usernameTLC
        toLanguageController.emailFLC = self.emailTLC
        self.navigationController?.pushViewController(toLanguageController, animated: true)
    }
}
