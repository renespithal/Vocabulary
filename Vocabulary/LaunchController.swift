//
//  LaunchViewController.swift
//  Vocabulary
//
//  Created by Margaretha Lucha on 05.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import VSSocialButton
import Foundation
import RealmSwift



class LaunchController: StyleableViewController {
    
    let loginbutton: UIButton = {
        
        let loginButton = UIButton()
        loginButton.tintColor = UIColor.white
        loginButton.backgroundColor = UIColor.black
        loginButton.setTitle("Log in", for: .normal)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        return loginButton
    }()
    
    
    let signupbutton: UIButton = {
        let signupButton = UIButton()
        signupButton.tintColor = UIColor.white
        signupButton.backgroundColor = standardColor
        signupButton.setTitle("Register", for: .normal)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        return signupButton
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style: .plain, target: nil, action: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "splashblurry")
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
         loginbutton.addTarget(self, action: #selector(pressLoginButton(sender:)), for: .touchUpInside)
        signupbutton.addTarget(self, action: #selector(pressSignUpButton(sender:)), for: .touchUpInside)
        self.view.addSubview(loginbutton)
        self.view.addSubview(signupbutton)
        self.view = view
        
        
        loginbutton.translatesAutoresizingMaskIntoConstraints = false
        loginbutton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true //left
        loginbutton.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true //right
        loginbutton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -50 ).isActive = true
        loginbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        signupbutton.translatesAutoresizingMaskIntoConstraints = false
        signupbutton.leadingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true //left
        signupbutton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true //right
        signupbutton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -50 ).isActive = true
        signupbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
  
    
    
    
    func pressLoginButton(sender: UIButton){
        self.navigationController?.pushViewController(LoginController(), animated: true)
    }
    
    func pressSignUpButton(sender: UIButton){
        self.navigationController?.pushViewController(SignupController(), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
