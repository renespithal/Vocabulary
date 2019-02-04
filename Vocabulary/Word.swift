//
//  Word.swift
//  Vocabulary
//
//  Created by Alex on 13/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import Foundation
import RealmSwift

class Word: Object {
    dynamic var name : String = ""
    dynamic var translation : String = ""
    dynamic var comment : String?
    dynamic var lastRepeat : NSDate?
    dynamic var lastSuccessfulRepeat : NSDate?
    //dynamic var language : Language!
    //dynamic var collection : Collection?
    dynamic var isFavorite = false
    var keywords: List<Keyword>?


    var wordLevel = RealmOptional<Int>()
    var rightAnswers = RealmOptional<Int>()
    var wrongAnswers = RealmOptional<Int>()


    dynamic var identifier = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "identifier"
    }

}
