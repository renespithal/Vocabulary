//
//  StudyAction.swift
//  Vocabulary
//
//  Created by Alex on 25.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift

class StudyAction: Object {

    dynamic var wordKnown = false
    dynamic var day: String = ""
    
    dynamic var identifier = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}
