//
//  Course.swift
//  Vocabulary
//
//  Created by Alex on 21/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift

class Course: Object {
    dynamic var name : String = ""
    dynamic var comment : String?
    dynamic var fromLanguage : String = ""
    dynamic var toLanguage : String = ""
    dynamic var customFromLanguage : String = ""
    dynamic var customToLanguage : String = ""
    //dynamic var language : Language?

    
    
    let collections = List<Collection>()
    
    dynamic var identifier = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}
