//
//  Language.swift
//  Vocabulary
//
//  Created by Alex on 13/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import Foundation
import RealmSwift

class Language: Object {
    dynamic var user : User?
    dynamic var fromLanguage : String = ""
    dynamic var toLanguage : String = ""
    dynamic var customFromLanguage : String = ""
    dynamic var customToLanguage : String = ""
    dynamic var comment : String?
    
    let courses = List<Course>()
    let collections = List<Collection>()
    let words = List<Word>()
    let favorites = List<Word>()

    
    dynamic var identifier = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}
