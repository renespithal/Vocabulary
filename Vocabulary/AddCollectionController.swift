//
//  EditProfileViewController.swift
//  Former-Demo
//
//  Created by Alex on 13/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import Former
import RealmSwift
import Localize_Swift
import Presentr

class AddCollectionController: FormViewController {
    
    var name : String = ""
    var comment : String?
    var language: Language?
    var languages = List<Language>()
    
    
    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        former.becomeEditingNext()
    }
    
    func viewSetup(){
        self.title = "Add List".localized()
                
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style: .plain, target: nil, action: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save".localized(), style: .done, target: self, action: #selector(save))
        
        self.navigationItem.rightBarButtonItem?.isEnabled = name.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0
        
        if language == nil && languages.count > 0 {
            language = languages[0]
        }
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func save() {
        RealmHelper.sharedInstance.createCollection(name: name, comment: comment, language: language!)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Private
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    func configure() {
        let nameRow = TextFieldRowFormer<FormTextFieldCell>() { [weak self] in
            $0.titleLabel.text = "Name".localized()
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add list name".localized()
                $0.text = self.name
            }.onTextChanged {
                self.navigationItem.rightBarButtonItem?.isEnabled = $0.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0
                self.name = $0
        }
        
        
        let languageDictionaryRow = createSelectorRow("Language".localized(), GeneralHelper.sharedInstance.languageForCode(code: (language?.fromLanguage)!) + " - " + GeneralHelper.sharedInstance.languageForCode(code: (language?.toLanguage)!), selectLanguage())

        
        let descriptionRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .black
            $0.textView.font = .systemFont(ofSize: 15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add description (optional)".localized()
                $0.text = self.comment
            }.onTextChanged {
                self.comment = $0
        }
        
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 0
                    $0.text = text
            }
        }
        
        let introductionSection = SectionFormer(rowFormer: nameRow, languageDictionaryRow, descriptionRow)
            .set(headerViewFormer: createHeader(""))
        
        
        former.removeAll().append(sectionFormer: introductionSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }
    
    let createSelectorRow = { (
        text: String,
        subText: String,
        onSelected: ((RowFormer) -> Void)?
        ) -> RowFormer in
        return LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.subTextLabel.textColor = .black
            $0.subTextLabel.font = .boldSystemFont(ofSize: 14)
            $0.accessoryType = .disclosureIndicator
            }.configure { form in
                _ = onSelected.map { form.onSelected($0) }
                form.text = text
                form.subText = subText
        }
    }

    
    private func selectLanguage() -> (RowFormer) -> Void {
        return { [weak self] rowFormer in
        let controller = SelectLanguageController()
        controller.languages = self?.languages
        controller.currentLanguage = self?.language
        controller.delegate = self
        self?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension AddCollectionController: SelectLanguageDelegate {
    func didSelectLanguage(newLanguage: Language) {
        language = newLanguage
        configure()
        tableView.reloadData()
    }
}
