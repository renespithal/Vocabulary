//
//  UserLoginViewController.swift
//  Vocabulary
//
//  Created by Margaretha Lucha on 05.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import VSSocialButton
import Former
import RealmSwift
import SVProgressHUD
import FBSDKLoginKit

class LoginController: FormViewController, FBSDKLoginButtonDelegate {
    var loginFinishCalled = false

    var username: String = ""
    var password: String = ""
    var mailaddress: String = ""
    
    var notificationToken: NotificationToken?
    
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    private var nameRow: TextFieldRowFormer<FormTextFieldCell>?
    private var passwordRow: TextFieldRowFormer<FormTextFieldCell>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    deinit{
        notificationToken?.stop()
    }
    
    private func configure() {
        title = "Login"
        tableView.contentInset.top = 40
        tableView.contentInset.bottom = 40
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Create RowFomers
        
        nameRow = TextFieldRowFormer<FormTextFieldCell>() { [weak self] in
            $0.titleLabel.text = "E-Mail"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "E-Mail"
                $0.text = mailaddress
            }.onTextChanged {[weak self] in
                self?.nameRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .black
                }

                self?.mailaddress = $0
                
        }
        
        passwordRow = TextFieldRowFormer<FormTextFieldCell>() { [weak self] in
            $0.titleLabel.text = "Password"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            $0.textField.isSecureTextEntry = true
            }.configure {
                $0.placeholder = "Password"
                $0.text = password
            }.onTextChanged {[weak self] in
                self?.passwordRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .black
                }

                self?.password = $0
                
        }
        
        let loginRow = LabelRowFormer<CenterLabelCell>()
            .configure {
                $0.text = "Log in"
            }.onSelected { [weak self] _ in
                self?.former.deselect(animated: true)
              
                self?.login(username:(self?.mailaddress)!, password:(self?.password)!)
                
                }
        
        let createSpaceHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>() {
                $0.contentView.backgroundColor = .clear
                }.configure {
                    $0.viewHeight = 5
            }
        }


        
        let introductionSection = SectionFormer(rowFormer: nameRow!, passwordRow!)
        
        let loginSection = SectionFormer(rowFormer: loginRow)
            .set(headerViewFormer: createSpaceHeader())
        
        former.append(sectionFormer:introductionSection, loginSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
        
        //Trennlinie erstellen
        let line = UIView(frame: CGRect(x: 10, y: 220, width: view.frame.width - 20, height: 1))
        line.backgroundColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)
        view.addSubview(line)
        
        //Facebook-Login-Button erzeugen
        let fbloginButton = FBSDKLoginButton()
        fbloginButton.frame = CGRect(x: 5, y: 255, width: view.frame.width - 10, height:50)
        fbloginButton.translatesAutoresizingMaskIntoConstraints = false
        fbloginButton.delegate = self
        view.addSubview(fbloginButton)
        
        let marginsView = view.layoutMarginsGuide
        
        fbloginButton.leadingAnchor.constraint(equalTo: marginsView.leadingAnchor).isActive = true //left
        fbloginButton.trailingAnchor.constraint(equalTo: marginsView.trailingAnchor).isActive = true //right
        fbloginButton.topAnchor.constraint(equalTo: marginsView.topAnchor, constant: 255 ).isActive = true
        fbloginButton.bottomAnchor.constraint(equalTo: marginsView.topAnchor, constant: 295 ).isActive = true
       
        
    }
    
    //Server-Login:
    func login(username: String, password: String) {
        
        let usernameCredentials = SyncCredentials.usernamePassword(username: username, password: password)
        
        SyncUser.logIn(with: usernameCredentials, server: serverURL!) { user, error in
            if let user = user {
                DispatchQueue.main.async {
                    SVProgressHUD.showProgress(0)
                    RealmHelper.sharedInstance.setUser()
                    let session = user.session(for: realmURL!)
                    //Man muss warten, bis die App die Daten von Realm runterlädt und wir das User Objekt haben
                    //erst dann kann der richtige Controller gepushed werden
                    self.notificationToken = session?.addProgressNotification(for: .download,
                                                                              mode: .forCurrentlyOutstandingWork) { progress in
                                                                                SVProgressHUD.showProgress(Float(progress.fractionTransferred))
                                                                                if progress.isTransferComplete {
                                                                                    self.loginFinished()
                                                                                }
                    }
                }
            } else if error != nil {
                SVProgressHUD.showError(withStatus: "Invalid email or password")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                    SVProgressHUD.dismiss()
                }
                return
            }
        }
    }

    
    
    //Funktionen für Facebook-Login
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of Facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(result.isCancelled){
            return
        }
        if(error != nil){
            print(error)
            return
        }
        let facebookCredentials = SyncCredentials.facebook(token: FBSDKAccessToken.current().tokenString)
        SyncUser.logIn(with: facebookCredentials, server: serverURL!) { user, error in
            if let user = user {
                DispatchQueue.main.async {
                    SVProgressHUD.showProgress(0)
                    RealmHelper.sharedInstance.setUser()
                    let session = user.session(for: realmURL!)
                    self.notificationToken = session?.addProgressNotification(for: .download,
                                                                             mode: .forCurrentlyOutstandingWork) { progress in
                                                                                SVProgressHUD.showProgress(Float(progress.fractionTransferred))
                                                                                if progress.isTransferComplete {
                                                                                    self.loginFinished()
                                                                                }
                    }
                }
            } else if error != nil {
                SVProgressHUD.showError(withStatus: "Problem with facebook login")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    SVProgressHUD.dismiss()
                }
            }
        }
        
        print("Successfully logged in with facebook")
    }
    
    func loginFinished() {
        if !loginFinishCalled {
            loginFinishCalled = true
            notificationToken?.stop()
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                let userResults = RealmHelper.sharedInstance.realm.objects(User.self)
                if userResults.count > 0 {
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.configureTabBarController()
                    appDelegate.window?.swapRootViewControllerWithAnimation(newViewController: appDelegate.tabBarController, animationType: .Push)
                } else {
                    let languageController = ToLanguageController()
                    self.navigationController?.pushViewController(languageController, animated: true)
                }
            }
        }
        
    }
    
}
