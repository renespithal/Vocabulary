//
//  RealmHelper.swift
//  Vocabulary
//
//  Created by Alex on 19/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift

class RealmHelper: NSObject {
    static let sharedInstance = RealmHelper()
    
    var realm: Realm = {
        if SyncUser.current == nil {
            return try! Realm()
        } else {
            var config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: realmURL!))
            Realm.Configuration.defaultConfiguration = config
            return try! Realm(configuration: config)
        }
    }()
    
    func setUser() {
        if SyncUser.current == nil {
            realm = try! Realm()
        } else {
            print("setuser")
            let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: realmURL!))
            Realm.Configuration.defaultConfiguration = config
            realm = try! Realm(configuration: config)
        }
    }
    
    
    func languagesCount() -> Int {
        let languageResults = realm.objects(Language.self)
        return languageResults.count
    }
    
     
    func createLanguage(fromLanguage: String, toLanguage: String, custom: Bool, comment: String?, user: User!) {
        let language = Language()
        if custom {
            language.customFromLanguage = fromLanguage
            language.customToLanguage = toLanguage
        } else {
            language.fromLanguage = fromLanguage
            language.toLanguage = toLanguage
        }
        language.comment = comment
        
        realm.beginWrite()
        realm.add(language)
        user.languages.append(language)
        try! realm.commitWrite()
    }
    
    func createCollection(name: String, comment: String?, language: Language) {
        let collection = Collection()
        collection.name = name
        collection.comment = comment
        
        realm.beginWrite()
        realm.add(collection)
        language.collections.append(collection)
        try! realm.commitWrite()
    }
    
    func createWord(name: String, translation: String, comment: String?, keywords: List<Keyword>?, language: Language, collection: Collection?) {
        let word = Word()
        word.name = name
        word.translation = translation
        word.comment = comment
        word.keywords = keywords

        
        realm.beginWrite()
        realm.add(word)
        if collection != nil {
            collection?.words.append(word)
        }
        language.words.append(word)
        try! realm.commitWrite()
    }
        
}
