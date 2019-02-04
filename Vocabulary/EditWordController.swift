//
//  EditWordController.swift
//  Vocabulary
//
//  Created by Alex on 02.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit

class EditWordController: AddWordController {
    var word: Word?
    
    override func viewSetup() {
        super.viewSetup()
        self.title = "Edit Word".localized()
        name = (word?.name)!
        translation = (word?.translation)!
        comment = word?.comment
    }
    
    override func save() {
        RealmHelper.sharedInstance.realm.beginWrite()
        word?.name = name
        word?.translation = translation
        word?.comment = comment
        try! RealmHelper.sharedInstance.realm.commitWrite()
        
        
        self.dismiss(animated: true, completion: nil)
    }
}
