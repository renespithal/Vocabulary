//
//  StudySession.swift
//  Vocabulary
//
//  Created by Alex on 25.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift

class StudySession: Object {
    
    dynamic var day: String = ""
    dynamic var language : Language?
    dynamic var collection : Collection?

    let studyActions = List<StudyAction>()
    
    dynamic var identifier = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}
