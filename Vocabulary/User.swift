//
//  User.swift
//  Vocabulary
//
//  Created by Alex on 13/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    //dynamic var useNightMode = false
    
    dynamic var hasLogedInWithFB : Bool = false
    dynamic var signupUsername : String = ""
    dynamic var signupEmail : String = ""
    dynamic var signupFBCredentials = ""
    
    
    let languages = List<Language>()
    
    dynamic var identifier = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}
