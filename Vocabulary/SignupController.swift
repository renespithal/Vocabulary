//
//  SignupViewController.swift
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


class SignupController: FormViewController, FBSDKLoginButtonDelegate {
    
    var username : String = ""
    var email : String = ""
    var password : String = ""
        
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    private var nameRow: TextFieldRowFormer<FormTextFieldCell>?
    private var mailRow: TextFieldRowFormer<FormTextFieldCell>?
    private var passwordRow: TextFieldRowFormer<FormTextFieldCell>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        tableView.contentInset.top = 40
        tableView.contentInset.bottom = 40
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Create RowFomers:
        
        nameRow = TextFieldRowFormer<FormTextFieldCell>() { [weak self] in
            $0.titleLabel.text = "Name"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Name"
                $0.text = username
            }.onTextChanged { [weak self] in
                self?.nameRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .black
                }
                self?.username = $0
        }
        
        mailRow = TextFieldRowFormer<FormTextFieldCell>() { [weak self] in
            $0.titleLabel.text = "E-Mail"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "E-Mail"
                $0.text = username
            }.onTextChanged { [weak self] in
                self?.mailRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .black
                }
                self?.email = $0
        }
        
        passwordRow = TextFieldRowFormer<FormTextFieldCell>() { [weak self] in
            $0.titleLabel.text = "Password"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            $0.textField.isSecureTextEntry = true
            }.configure {
                $0.placeholder = "Password"
                $0.text = username
            }.onTextChanged { [weak self] in
                self?.passwordRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .black
                }
                self?.password = $0
        }
        
        
        
        let signupRow = LabelRowFormer<CenterLabelCell>()
            .configure {
                $0.text = "Register"
            }.onSelected { [weak self] _ in
                self?.former.deselect(animated: true)
                
                self?.checkInput(un: (self?.username)!,ma: (self?.email)!,pw: (self?.password)!)
        }
        
        //create space header for signup-button
        let createSpaceHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>() {
                $0.contentView.backgroundColor = .clear
                }.configure {
                    $0.viewHeight = 5
            }
        }
        
        
        let introductionSection = SectionFormer(rowFormer: nameRow!, mailRow!, passwordRow!)
        
        let signupSection = SectionFormer(rowFormer: signupRow)
            .set(headerViewFormer: createSpaceHeader())
        
        former.append(sectionFormer:introductionSection, signupSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
        
        
        let marginsView = view.layoutMarginsGuide
        
        //Trennlinie erstellen
        
        let line = UIView()
        line.backgroundColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)
        line.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(line)
        
        line.leadingAnchor.constraint(equalTo: marginsView.leadingAnchor).isActive = true //left
        line.trailingAnchor.constraint(equalTo: marginsView.trailingAnchor).isActive = true //right
        line.bottomAnchor.constraint(equalTo: marginsView.topAnchor, constant: 265 ).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        
        //Facebook-Login-Button erzeugen
        
        let fbloginButton = FBSDKLoginButton()
        fbloginButton.delegate = self
        fbloginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fbloginButton)
        
        fbloginButton.leadingAnchor.constraint(equalTo: marginsView.leadingAnchor).isActive = true //left
        fbloginButton.trailingAnchor.constraint(equalTo: marginsView.trailingAnchor).isActive = true //right
        fbloginButton.topAnchor.constraint(equalTo: marginsView.topAnchor, constant: 300 ).isActive = true
        fbloginButton.bottomAnchor.constraint(equalTo: marginsView.topAnchor, constant: 340 ).isActive = true

    }

    
    //Überprüfe alle Benutzereingaben
    
    func checkInput(un: String, ma: String, pw: String){
        
        if(((un.characters.count) < 2 ) || ((un.characters.count) > 25) || ((self.validateEmailAddress(email: (ma))) == false) || ((pw.characters.count) < 8) || ((pw.characters.count) > 30)){
            
            if((un.characters.count) < 2 || (un.characters.count) > 25){
                
                self.nameRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .red
                }
                self.nameRow!.update { row in
                    row.text = ""
                    row.placeholder = "Please enter 2 to 25 characters."
                    
                }
                
            }
            
            if((self.validateEmailAddress(email: (ma))) == false){
                
                self.mailRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .red
                }
            }
            
            if((pw.characters.count) < 8 || (pw.characters.count) > 30){
                
                self.passwordRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .red
                }
                self.passwordRow!.update { row in
                    row.text = ""
                    row.placeholder = "Please enter at least 8 characters."
                    
                }
            }
            
            //Passwort darf kein Leerzeichen enthalten
            let passwordArray = Array(pw.characters)
            
            for p in passwordArray{
                let ps = String(p)
                if(ps == " "){
                    self.passwordRow!.cellUpdate { cell in
                        cell.titleLabel.textColor = .red
                    }
                    self.passwordRow!.update { row in
                        row.text = ""
                        row.placeholder = "Please enter at least 8 characters."
                    }
                   
                    SVProgressHUD.showError(withStatus: "Invalid password")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                        SVProgressHUD.dismiss()
                    }
                    return
                }
            }
            
            if((self.validateEmailAddress(email: (ma)) == false)){
                
                self.mailRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .red
                }
                //show error message
                SVProgressHUD.showError(withStatus: "Invalid E-Mail address")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    SVProgressHUD.dismiss()
                }
            }
            //Wenn eine oder mehrere Sachen falsch sind, abbrechen
            return
            
        }
        
        //prüfen, ob username nur aus buchstaben und/oder zahlen und/oder -_. besteht
        let letters = CharacterSet.letters
        let numbers = CharacterSet.decimalDigits
        var validCharacters = CharacterSet.init(charactersIn: "-_.")
        validCharacters.formUnion(letters)
        validCharacters.formUnion(numbers)
        
        let usernameArray = Array(un.characters)
        
        for u in usernameArray{
            let us = String(u)
            if(us.rangeOfCharacter(from: validCharacters) == nil){
                
                self.nameRow!.cellUpdate { cell in
                    cell.titleLabel.textColor = .red
                }
                self.nameRow!.update { row in
                    row.text = ""
                    row.placeholder = "Please enter 2 to 25 characters."
                    
                }
                SVProgressHUD.showError(withStatus: "Your username should only contain letters, numbers and symbols(.,-,_)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                    SVProgressHUD.dismiss()
                }
                
                return
            }
            
        }
        
        //wenn alle tests bestanden wurden, kann für den user ein account erstellt werden
        self.signup(name: un, email: ma, password: pw)
    }
    
    
    
    
    
    func validateEmailAddress(email:String) -> Bool {
        
        let format = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", format)
        return emailPredicate.evaluate(with: email)
        
    }
    
    
    
    //Server-SignUp:
    
    func signup(name: String, email: String, password: String) {
        
        let usernameCredentials = SyncCredentials.usernamePassword(username: email, password: password, register: true)
        SyncUser.logIn(with: usernameCredentials,
                       server: serverURL!) { user, error in
                        if user != nil {
                           
                            RealmHelper.sharedInstance.setUser()
 
                            SVProgressHUD.showSuccess(withStatus: "Welcome!")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                SVProgressHUD.dismiss()
                                let languageController = ToLanguageController()
                                languageController.usernameTLC = name
                                languageController.emailTLC = email
                                self.navigationController?.pushViewController(languageController, animated: true)
                              
                            }
                            //An error will be thrown if your application tries to register a new user with the username of an existing user
                        } else if error != nil {
                            self.userErrorHandler()
                        }
        }
    }
    
    
    
    
    func userErrorHandler(){
        self.mailRow!.cellUpdate { cell in
            if(cell.titleLabel.textColor == .black ){
            cell.titleLabel.textColor = .red 
            }
        }
        SVProgressHUD.showError(withStatus: "E-Mail address already registered")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            SVProgressHUD.dismiss()
        }
        
        return
        
        
    }
    
    
    
    // Facebook-Login Funktionen
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of Facebook")
        FBSDKLoginManager().logOut()
        FBSDKAccessToken.setCurrent(nil)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if(result.isCancelled){
            return
        }
        if(error != nil){
            print(error)
            return
        }
        
        self.enterWithFacebook()
        
        print("Successfully logged in with facebook")
    }
    
    func enterWithFacebook() {
        let facebookCredentials = SyncCredentials.facebook(token: FBSDKAccessToken.current().tokenString)
    
        SyncUser.logIn(with: facebookCredentials, server: serverURL!) { user, error in //oder register?
            if user != nil {
               
                RealmHelper.sharedInstance.setUser()
                
                SVProgressHUD.showSuccess(withStatus: "Welcome!")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    SVProgressHUD.dismiss()
                    let languageController = ToLanguageController()
                    self.navigationController?.pushViewController(languageController, animated: true)
                }
                
            } else if error != nil {
                
                SVProgressHUD.showError(withStatus: "Problem with facebook login")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    
    
}




