//
//  VDictionary.swift
//  Vocabulary
//
//  Created by Alex on 13/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import Foundation
import RealmSwift

class Collection: Object {
    dynamic var name : String = ""
    dynamic var comment : String?
    //dynamic var language : Language?
    dynamic var course : Course?
    let words = List<Word>()
    
    
    dynamic var identifier = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

