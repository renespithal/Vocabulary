//
//  EditCollectionController.swift
//  Vocabulary
//
//  Created by Alex on 02.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import Former
import RealmSwift
import Localize_Swift
import Presentr

class EditCollectionController: AddCollectionController {
    var collection: Collection?
    
    override func viewSetup() {
        super.viewSetup()
        self.title = "Edit Collection".localized()
        name = (collection?.name)!
    }

    override func save() {
        RealmHelper.sharedInstance.realm.beginWrite()
        collection?.name = name
        try! RealmHelper.sharedInstance.realm.commitWrite()
        self.dismiss(animated: true, completion: nil)
    }
}
