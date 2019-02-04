//
//  CardViewController.swift
//  Vocabulary
//
//  Created by Margaretha Lucha on 13.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//



import UIKit
import Koloda
import RealmSwift



class CardViewController: StyleableViewController{
    
    var realm = RealmHelper.sharedInstance.realm
    var user : User!
    var userResults : Results<User>!
    var userToken : NotificationToken!
    var languageToken : NotificationToken!
    var languages: List<Language>?
    var language : Language!
    var collection : Collection!
    
    var i = 1
    var selector : Int!
 
    var yesButton = UIButton()
    var noButton = UIButton()
    var showButton = UIButton()
    var translationLabel = UILabel()
    var wordLabel = UILabel()
    var tempCardView = UIView()
    var cardView = UIView()
    
    var regularConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    //Variables for creating studySession and studyActions:
    let studySession = StudySession()
    var studyActions: List<StudyAction>?
    var today: Date!
    var dateFormatter = DateFormatter()
    var date: String = ""
   
   

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Cancel".localized(), style: .done, target: self, action: #selector(cancel))
    
        //StudySession------:
        today = Date()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        date = dateFormatter.string(from: today)
        createStudySession()
        
        
        self.cardView.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor(red: 230.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        
        let rightButtonImage = UIImage(named:"CardView_right_button_colored_64")
        let wrongButtonImage = UIImage(named:"CardView_wrong_button_colored_64")
        let showButtonImage = UIImage(named:"eye")
        
        yesButton.setImage(rightButtonImage, for: .normal)
        noButton.setImage(wrongButtonImage, for: .normal)
        showButton.setImage(showButtonImage, for: .normal)
        showButton.imageView?.tintColor = UIColor.white
        yesButton.tag = 1
        noButton.tag = 0
        
        showButton.addTarget(self, action: #selector(showTranslation), for: .touchUpInside)
        yesButton.addTarget(self, action: #selector(createStudyAction(sender:)), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(createStudyAction(sender:)), for: .touchUpInside)
       
        self.view.addSubview(yesButton)
        self.view.addSubview(noButton)
        self.view.addSubview(showButton)
    
        self.view.addSubview(cardView)
        
        
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        yesButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 70).isActive = true
        yesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        yesButton.widthAnchor.constraint(equalToConstant: 70.0).isActive = true
        yesButton.heightAnchor.constraint(equalToConstant: 70.0).isActive = true

        noButton.translatesAutoresizingMaskIntoConstraints = false
        noButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -70).isActive = true
        noButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        noButton.widthAnchor.constraint(equalToConstant: 70.0).isActive = true
        noButton.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: -35).isActive = true
        showButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        showButton.widthAnchor.constraint(equalToConstant: 70.0).isActive = true
        showButton.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        if UIScreen.main.bounds.size.width < 375{
            regularConstraints.append(contentsOf: [cardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
                                                    cardView.heightAnchor.constraint(equalToConstant: 150),
                                                   cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                                                   cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)])
        
        }else{
            regularConstraints.append(contentsOf: [cardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 140),
                                               cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -250),
                                               cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                                               cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)])
        }
        
        landscapeConstraints.append(contentsOf: [cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110),
                                                   cardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
                                                   cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
                                                 cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100)])
        
        
        self.cardView.addSubview(wordLabel)
        self.cardView.addSubview(translationLabel)
        
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: -20).isActive = true
        wordLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor).isActive = true
        wordLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor).isActive = true
        wordLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        
        
        wordLabel.textAlignment = .center
        wordLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        
        translationLabel.translatesAutoresizingMaskIntoConstraints = false
        translationLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 60).isActive = true
        translationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor).isActive = true
        translationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor).isActive = true
        translationLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        
        translationLabel.textAlignment = .center
        translationLabel.font = UIFont.systemFont(ofSize: 21.0)
        
        
        var word = Word()
       
        //case1: All words selected, case2: favorites selected, case3: list selected
        switch selector {
        case 1:
           
            if(language.words.count > 0){
                word = language.words[0]
                wordLabel.text = word.name
                
                translationLabel.text = word.translation
                translationLabel.isHidden = true
            }else{
                wordLabel.text = "Pls add some words"
                showButton.isEnabled = false
                yesButton.isEnabled = false
                noButton.isEnabled = false
            }
           
        case 2:
 
        if(language.favorites.count > 0){
            word = language.favorites[0]
            wordLabel.text = word.name
            
            translationLabel.text = word.translation
            translationLabel.isHidden = true
        }else{
            wordLabel.text = "Pls add some words"
            showButton.isEnabled = false
            yesButton.isEnabled = false
            noButton.isEnabled = false
            }
            
        case 3:
           
            if (collection.words.count > 0) {
                word = collection.words[0]
                wordLabel.text = word.name
                
                translationLabel.text = word.translation
                translationLabel.isHidden = true
            }else{
                wordLabel.text = "Pls add some words"
                showButton.isEnabled = false
                yesButton.isEnabled = false
                noButton.isEnabled = false
            }
            
        default:
            print("fail")
        }
    }

    func cancel(){

        self.dismiss(animated: true, completion: nil)
        
    }
    
   
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
        if ((self.view.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass)
            || (self.view.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass)) {
            
            if(self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact){
                NSLayoutConstraint.deactivate(regularConstraints)
                NSLayoutConstraint.activate(landscapeConstraints)
            }
            else{
                NSLayoutConstraint.deactivate(landscapeConstraints)
                NSLayoutConstraint.activate(regularConstraints)
            }
        }
    }

    
    func showTranslation(){
        
        if(selector == 1 && language.words.count >= i){
                translationLabel.text = language.words[i-1].translation
                translationLabel.isHidden = false
        }
        else if(selector == 2 && language.favorites.count >= i){
                translationLabel.text = language.favorites[i-1].translation
                translationLabel.isHidden = false
            }
        else if (selector == 3 && collection.words.count >= i){
                translationLabel.text = collection.words[i-1].translation
                translationLabel.isHidden = false
            }
        else{
                translationLabel.isHidden = true
            }
        
        //update cardview:
        tempCardView.setNeedsLayout()
        tempCardView.layoutIfNeeded()
        
        
    }
    
    func showNextCard(){

        if(selector == 1 && language.words.count > i){
          
            wordLabel.text = language.words[i].name
            wordLabel.textAlignment = .center
            translationLabel.isHidden = true

        }
        else if(selector == 2 && language.favorites.count > i){
           
                wordLabel.text = language.favorites[i].name
                wordLabel.textAlignment = .center
                translationLabel.isHidden = true
       
        }else if(selector == 3 && collection.words.count > i){

                wordLabel.text = collection.words[i].name
                wordLabel.textAlignment = .center
                translationLabel.isHidden = true
            
        }else{
                translationLabel.isHidden = true
                wordLabel.text = "Training finished!"
                showButton.isEnabled = false
                yesButton.isEnabled = false
                noButton.isEnabled = false
    
            
        }
        
        tempCardView.setNeedsLayout()
        tempCardView.layoutIfNeeded()
        i += 1
    }
    
    
    //MARK: Create StudySession and StudyActions
    
    func createStudyAction(sender: UIButton){
        
        let studyAction = StudyAction()
        
        if(sender.tag == 1){
            studyAction.wordKnown = true
        }else{
            studyAction.wordKnown = false
        }
        studyAction.day = date
        
        try! realm.write {
            RealmHelper.sharedInstance.realm.add(studyAction)
            studySession.studyActions.append(studyAction)
        }
        
        showNextCard()
    }
    

    func createStudySession(){
        
        studySession.collection = collection
        studySession.day = date
        studySession.language = language
       
        try! realm.write {
            RealmHelper.sharedInstance.realm.add(studySession)
        }
    }

}

