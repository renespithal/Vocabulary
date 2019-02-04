//
//  AddToLanguageController.swift
//  Vocabulary
//
//  Created by Alex on 18/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift

class FromLanguageController: ToLanguageController {
    public var toLanguageCode: String?
    
    //Neu:
    public var nameFLC: String = ""
    public var emailFLC: String = ""

    
    override init() {
        super.init()
        restorationIdentifier = String(describing: type(of: self))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetup()
    }
    
    override func viewSetup() {
        super.viewSetup()
        self.title = "In which language are you learning?".localized()
        self.navigationItem.hidesBackButton = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            createAndFinish(fromLanguageCode: userLanguages[indexPath.row])
        } else if indexPath.section == 1 {
            createAndFinish(fromLanguageCode: popularLanguages[indexPath.row])
        } else {
            if indexPath.row == 0 {
                
            } else {
                
            }
        }
    }
    
    func createAndFinish(fromLanguageCode: String){
        if user == nil {
            RealmHelper.sharedInstance.setUser()
            
            user = User()
            user!.signupUsername = self.nameFLC
            user!.signupEmail = self.emailFLC
            try! RealmHelper.sharedInstance.realm.write {
                RealmHelper.sharedInstance.realm.add(user!)
            }
            
            
        }
        
        RealmHelper.sharedInstance.createLanguage(fromLanguage: fromLanguageCode, toLanguage: toLanguageCode!, custom: false, comment: nil, user: user)
        
        if modalPresentation {
            // Post notification
            NotificationCenter.default.post(name: Notification.Name("CreatedLanguage"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
        } else {
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.configureTabBarController()
            appDelegate.window?.swapRootViewControllerWithAnimation(newViewController: appDelegate.tabBarController, animationType: .Push)

        }
    }
}

