//
//  SelectLanguageControllerViewController.swift
//  Vocabulary
//
//  Created by Alex on 28.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import Former
import RealmSwift

protocol SelectLanguageDelegate {
    func didSelectLanguage(newLanguage: Language)
}

class SelectLanguageController: StyleableTableViewController {
    var delegate: SelectLanguageDelegate?
    var languages: List<Language>?
    var currentLanguage: Language?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
    }
    
    override func viewSetup() {
        super.viewSetup()
        title = "Language".localized()
        tableView.separatorColor = .lightGray
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        let language = languages![indexPath.row]
        cell.textLabel?.text = GeneralHelper.sharedInstance.languageForCode(code: language.fromLanguage) + " - " + GeneralHelper.sharedInstance.languageForCode(code: language.toLanguage)

        if language == currentLanguage {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages![indexPath.row]
        didSelectLanguage(newLanguage: language)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func didSelectLanguage(newLanguage: Language) {
        delegate?.didSelectLanguage(newLanguage: newLanguage)
    }
}
