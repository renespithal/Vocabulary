//
//  AppDelegate.swift
//  Vocabulary
//
//  Created by Alex on 13/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import Branch
import UserNotifications
import FBSDKCoreKit
import RealmSwift
import ESTabBarController_swift
import EZAlertController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HyPopMenuViewDelegate {
    var user : User?
    var languages: List<Language>?
    var language : Language?
    var collections: List<Collection>?
    var collection: Collection?
    var word: Word?
    
    var window: UIWindow?
    
    let tabBarController = StyleableTabBarController()
    var gagatTransitionHandle: Gagat.TransitionHandle!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
      
        /*if UserDefaults.standard.bool(forKey: "FirstLaunch") {
            UserDefaults.standard.set(false, forKey: "FirstLaunch")
            UserDefaults.standard.set(false, forKey: "NightMode")
        }*/
        
        if SyncUser.current == nil {
            window?.rootViewController = StyleableNavigationController.init(rootViewController:LaunchController())
            window?.makeKeyAndVisible()
        } else if SyncUser.current != nil && RealmHelper.sharedInstance.languagesCount() == 0 {
            window?.rootViewController = StyleableNavigationController.init(rootViewController:ToLanguageController())
            window?.makeKeyAndVisible()
        } else {
            window?.rootViewController = tabBarController
            
            let configuration = Gagat.Configuration(jellyFactor: 1.5)
            let styleableViewController = window!.rootViewController as! GagatStyleable
            gagatTransitionHandle = Gagat.configure(for: window!, with: styleableViewController, using: configuration)
            window?.makeKeyAndVisible()
            configureTabBarController()
        }
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(createdLanguage), name: Notification.Name("CreatedLanguage"), object: nil)
        

        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, automaticallyDisplayDeepLinkController: true, deepLinkHandler: { params, error in
            if error == nil {

            }
        })
        return true
}
    
    func configureTabBarController() {
        if let tabBar = tabBarController.tabBar as? ESTabBar {
            tabBar.itemCustomPositioning = .fillIncludeSeparator
            tabBar.tintColor = standardColor
            tabBar.backgroundColor = UIColor.white
        }
        
        let collection = StyleableNavigationController.init(rootViewController: LanguageController())
        let study = StyleableNavigationController.init(rootViewController: UIViewController())
        let addWord = StyleableNavigationController.init(rootViewController: UIViewController())
        let search = StyleableNavigationController.init(rootViewController: SearchController())
        let more = StyleableNavigationController.init(rootViewController: MoreTableViewControllerIB())
        
        let firstButtonView = NormalButtonView()
        firstButtonView.firstSelectAnimation = true
        
        collection.tabBarItem = ESTabBarItem.init(firstButtonView, title: nil, image: UIImage(named: "home"), selectedImage: UIImage(named: "home"))
        study.tabBarItem = ESTabBarItem.init(OtherContentView(), title: nil, image: UIImage(named: "study"), selectedImage: UIImage(named: "study"))
        addWord.tabBarItem = ESTabBarItem.init(MiddleButtonView.init(specialWithAutoImplies: true), title: nil, image: #imageLiteral(resourceName: "plus_rounded_corners_20"), selectedImage: UIImage(named: "plus"))
        search.tabBarItem = ESTabBarItem.init(OtherContentView(), title: nil, image: UIImage(named: "search"), selectedImage: UIImage(named: "search"))
        more.tabBarItem = ESTabBarItem.init(NormalButtonView(), title: nil, image: UIImage(named: "user"), selectedImage: UIImage(named: "user"))
        
        tabBarController.viewControllers = [collection, study, addWord, search, more]
        
        tabBarController.shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 1 || index == 2 || index == 3 {
                return true
            }
            return false
        }
        
        //Popup für Tab Bar Items in der Mitte
        tabBarController.didHijackHandler = {
            _, viewController, index in
            if index == 1 {
                self.showLearnMode()
            } else if index == 2 {
                self.showPopup()
            } else if index == 3 {
                self.showSearch()
            }
        }
    }
    
    
    func showLearnMode(){
        let studyController = StudyController2()
        studyController.language = self.language
        studyController.collection = self.collection
        studyController.collections = self.collections
        tabBarController.present(StyleableNavigationController.init(rootViewController: studyController), animated: true, completion: nil)
    }
    
      
    func showPopup() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let newWord = UIAlertAction(title: "New Word".localized(), style: .default) { action in
            self.addWord()
        }
        newWord.isEnabled = (languages?.count)! > 0
        alertController.addAction(newWord)
        
        let newList = UIAlertAction(title: "New List".localized(), style: .default) { action in
            self.addCollection()
        }
        newList.isEnabled = (languages?.count)! > 0
        alertController.addAction(newList)
            
        alertController.addAction(UIAlertAction(title: "New Language".localized(), style: .default) { action in
            self.addLanguage()
        })
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel) { action in
        })
        
        alertController.view.tintColor = actionSheetTintColor

               
        tabBarController.present(alertController, animated: true, completion: nil)
    }
    
    func addLanguage() {
        let fromLanguageController = ToLanguageController()
        fromLanguageController.user = user
        fromLanguageController.modalPresentation = true
        let addLanguageController = StyleableNavigationController.init(rootViewController:fromLanguageController)
        tabBarController.present(addLanguageController, animated: true, completion: nil)
    }
    
    func addCollection() {
        let addCollectionController = AddCollectionController()
        if self.languages != nil {
            addCollectionController.languages = languages!
        }
        addCollectionController.language = language
        tabBarController.present(StyleableNavigationController.init(rootViewController: addCollectionController), animated: true, completion: nil)
    }
    
    func editCollection() {
        let addCollectionController = EditCollectionController()
        if self.languages != nil {
            addCollectionController.languages = languages!
        }
        addCollectionController.language = language
        addCollectionController.collection = collection
        tabBarController.present(StyleableNavigationController.init(rootViewController: addCollectionController), animated: true, completion: nil)
    }
    
    func addWord(){
        let addWordController = AddWordController()
        addWordController.language = self.language
        if self.languages != nil {
            addWordController.languages = self.languages!
        }
        addWordController.collection = self.collection
        if self.collections != nil {
            addWordController.collections = self.collections!
        }
        tabBarController.present( StyleableNavigationController.init(rootViewController: addWordController), animated: true, completion: nil)
    }
    
    func editWord(){
        let addWordController = EditWordController()
        addWordController.language = self.language
        if self.languages != nil {
            addWordController.languages = self.languages!
        }
        addWordController.collection = self.collection
        if self.collections != nil {
            addWordController.collections = self.collections!
        }
        addWordController.word = word
        tabBarController.present( StyleableNavigationController.init(rootViewController: addWordController), animated: true, completion: nil)
    }
    
    
    
    
    func showSearch(){
        let searchController = SearchController()
        searchController.language = self.language
        searchController.collection = self.collection
        searchController.collections = self.collections
        tabBarController.present(StyleableNavigationController.init(rootViewController: searchController), animated: true, completion: nil)
    }
    
    func createdLanguage() {
        print("createdLanguage")
        let viewController = tabBarController.viewControllers?[0] as! UINavigationController
        viewController.popToRootViewController(animated: true)
    }
    
    // MARK: - HyPopMenuViewDelegate
    
    func popMenuView(_ popMenuView: HyPopMenuView!, didSelectItemAt index: UInt) {
        
    }
    
    
    // Respond to URI scheme links
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().handleDeepLink(url);
    
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }

    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    // IMPORTANT: This method is not a substitute for saving your app’s data structures persistently to disk!
    func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        
    }
    
    func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
        
    }
    
    /*func application(application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
    }*/


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

public enum SwapRootVCAnimationType {
    case Push
    case Pop
    case Present
    case Dismiss
}


extension UIWindow {
    public func swapRootViewControllerWithAnimation(newViewController:UIViewController, animationType:SwapRootVCAnimationType, completion: (() -> ())? = nil) {
        guard let currentViewController = rootViewController else {
            return
        }
        
        let width = currentViewController.view.frame.size.width;
        let height = currentViewController.view.frame.size.height;
        
        var newVCStartAnimationFrame: CGRect?
        var currentVCEndAnimationFrame:CGRect?
        
        var newVCAnimated = true
        
        switch animationType
        {
        case .Push:
            newVCStartAnimationFrame = CGRect(x: width, y: 0, width: width, height: height)
            currentVCEndAnimationFrame = CGRect(x: 0 - width/4, y: 0, width: width, height: height)
        case .Pop:
            currentVCEndAnimationFrame = CGRect(x: width, y: 0, width: width, height: height)
            newVCStartAnimationFrame = CGRect(x: 0 - width/4, y: 0, width: width, height: height)
            newVCAnimated = false
        case .Present:
            newVCStartAnimationFrame = CGRect(x: 0, y: height, width: width, height: height)
        case .Dismiss:
            currentVCEndAnimationFrame = CGRect(x: 0, y: height, width: width, height: height)
            newVCAnimated = false
        }
        
        newViewController.view.frame = newVCStartAnimationFrame ?? CGRect(x: 0, y: 0, width: width, height: height)
        
        addSubview(newViewController.view)
        
        if !newVCAnimated {
            bringSubview(toFront: currentViewController.view)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            if let currentVCEndAnimationFrame = currentVCEndAnimationFrame {
                currentViewController.view.frame = currentVCEndAnimationFrame
            }
            
            newViewController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }, completion: { finish in
            self.rootViewController = newViewController
            completion?()
        })
        
        makeKeyAndVisible()
    }
}




