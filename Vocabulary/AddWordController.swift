//
//  AddWordViewController.swift
//  Vocabulary
//
//  Created by Alex on 13/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import Former
import RealmSwift
import Localize_Swift

class AddWordController: FormViewController {
    var name : String = ""
    var translation : String = ""
    var comment : String?
    var keywords = List<Keyword>()
    var languages = List<Language>()
    var language : Language?
    var collection: Collection?
    var collections = List<Collection>()
    
        
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
        self.title = "Add Word".localized()
        
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style: .plain, target: nil, action: nil)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

                
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save".localized(), style: .done, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        if language == nil && languages.count > 0 {
            language = languages[0]
            
            if collection == nil && language!.collections.count > 0 {
                collection = language!.collections[0]
            }
        }        
    }
    
    func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func save(){
        RealmHelper.sharedInstance.createWord(name: name, translation: translation, comment: comment, keywords: nil, language: language!, collection: collection)

        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Private
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    func configure() {
        // Create RowFomers
        
        let wordRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .black
            $0.textView.font = .systemFont(ofSize: 15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Word".localized()
                $0.text = self.name
            }.onTextChanged {
                self.name = $0
                self.navigationItem.rightBarButtonItem?.isEnabled = self.name.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 && self.translation.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0
        }
        
        wordRow.rowHeight = 75

        
        let indexPath = IndexPath(row: 0, section: 0)
        wordRow.cellSelected(indexPath: indexPath)
        
        let translationRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .black
            $0.textView.font = .systemFont(ofSize: 15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Translation".localized()
                $0.text = self.translation
            }.onTextChanged {
                self.translation = $0
                self.navigationItem.rightBarButtonItem?.isEnabled = self.name.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 && self.translation.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0
        }
        translationRow.rowHeight = 75
        
        
        let languageRow = createSelectorRow("Language".localized(), GeneralHelper.sharedInstance.languageForCode(code: (language?.fromLanguage)!) + " - " + GeneralHelper.sharedInstance.languageForCode(code: (language?.toLanguage)!), selectLanguage())

        
        let descriptionRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .black
            $0.textView.font = .systemFont(ofSize: 15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add a comment (optional)".localized()
                $0.text = self.comment
            }.onTextChanged {
                self.comment = $0
        }
        
        // Create Headers
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 44
                    $0.text = text
            }
        }
        
        // Create SectionFormers
        let languageSection = SectionFormer(rowFormer: wordRow).set(headerViewFormer: createHeader("Language".localized()))
        let translationSection = SectionFormer(rowFormer: translationRow).set(headerViewFormer: createHeader("Translation".localized()))
        
        if collections.count > 0 {
            if collection == nil {
                let collectionRow = createSelectorRow("List".localized(), "", selectCollection())
                
                let moreSection = SectionFormer(rowFormer:descriptionRow, languageRow, collectionRow).set(headerViewFormer: createHeader("More".localized()))
                
                former.removeAll().append(sectionFormer: languageSection, translationSection, moreSection)
                    .onCellSelected { [weak self] _ in
                        self?.formerInputAccessoryView.update()
                }
            } else {
                let collectionRow = createSelectorRow("List".localized(), collection!.name, selectCollection())
                
                let moreSection = SectionFormer(rowFormer:descriptionRow, languageRow, collectionRow).set(headerViewFormer: createHeader("More".localized()))
                
                former.removeAll().append(sectionFormer: languageSection, translationSection, moreSection)
                    .onCellSelected { [weak self] _ in
                        self?.formerInputAccessoryView.update()
                }
            }
            
        } else {
            let moreSection = SectionFormer(rowFormer:descriptionRow, languageRow).set(headerViewFormer: createHeader("More".localized()))
            
            former.removeAll().append(sectionFormer: languageSection, translationSection, moreSection)
                .onCellSelected { [weak self] _ in
                    self?.formerInputAccessoryView.update()
            }
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
            $0.subTextLabel.textColor = standardColor
            $0.subTextLabel.font = .boldSystemFont(ofSize: 14)
            $0.accessoryType = .disclosureIndicator
            }.configure { form in
                _ = onSelected.map { form.onSelected($0) }
                form.text = text
                form.subText = subText
        }
    }
    
    private func selectCollection() -> (RowFormer) -> Void {
        return { [weak self] rowFormer in
            let controller = SelectCollectionController()
            controller.collections = self?.collections
            controller.currentCollection = self?.collection
            controller.delegate = self
            self?.navigationController?.pushViewController(controller, animated: true)
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

extension AddWordController: SelectCollectionDelegate {
    func didSelectCollection(newCollection: Collection) {
        collection = newCollection
        configure()
        tableView.reloadData()
    }
}

extension AddWordController: SelectLanguageDelegate {
    func didSelectLanguage(newLanguage: Language) {
        language = newLanguage
        collections = language!.collections
        configure()
        tableView.reloadData()
    }
}
