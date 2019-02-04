//
//  GeneralHelper.swift
//  Vocabulary
//
//  Created by Alex on 10/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import Localize_Swift

class GeneralHelper {
    static let sharedInstance = GeneralHelper()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }

    let currentLocale = Locale.init(identifier: Localize.currentLanguage())
    
    let userLanguages = Locale.preferredLanguages
    
    let allLanguageCodes = Locale.availableIdentifiers
    
    func popularLanguages() -> Array<String> {
        let languages = NSMutableArray(array: ["ar", "zh", "cy", "da", "de", "en", "es", "fr", "it", "ja", "ko", "nl", "no", "pl", "pt", "ru", "sv", "tr"])
        
        for identifier in userLanguages {
            languages.remove(identifier)
        }
        return (languages as! Array<String>)
    }
    
    
    func languageForCode(code: String) -> String {
        let index = code.index(code.startIndex, offsetBy: 2)
        let code = code.substring(to: index)
        return currentLocale.localizedString(forLanguageCode: code)!
    }
    
    func flagForLanguageCode(code: String) -> UIImage? {
        let index = code.index(code.startIndex, offsetBy: 2)
        let shortenedCode = code.substring(to: index)
        
        if shortenedCode == "en" {
            if code == "en_US" {
                return UIImage(named: "flag-en-US")
            } else {
                return UIImage(named: "flag-en-UK")
            }
        }
        
        if shortenedCode == "es" {
            if code == "es_MX" {
                return UIImage(named: "flag-es-MX")
            } else {
                return UIImage(named: "flag-es-ES")
            }
        }
        
        if shortenedCode == "pt" {
            if code == "pt_BR" {
                return UIImage(named: "flag-pt-BR")
            } else {
                return UIImage(named: "flag-pt-PT")
            }
        }
        
        var flag = UIImage(named: String("flag-\(shortenedCode)"))
        
        if flag == nil {
            flag = UIImage(named: "flag-other")
        }
        
        return flag
    }
    
    func imageForDictionary(code1: String, code2: String) -> UIImage? {
    
        let topImage = flagForLanguageCode(code: code1)
        let bottomImage = flagForLanguageCode(code: code2)
    
        let size = CGSize.init(width: 32, height: 32)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    
        topImage!.draw(in: CGRect.init(x: 0, y: 0, width: 22, height: 22))
        bottomImage!.draw(in: CGRect.init(x: 10, y: 10, width: 22, height: 22))
    
        let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
    @objc func languageChanged() {
        
    }
    
}
