//
//  MoreTableViewControllerIB.swift
//  Vocabulary
//
//  Created by Tim Kraus on 11.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class MoreTableViewControllerIB: UITableViewController {
    
    
    var user : User?
    var userFirstName : String = ""
    var userLastName : String = ""
    var userIdentifier : String = "" 
    
    var userLanguages = GeneralHelper.sharedInstance.userLanguages
    var popularLanguages = GeneralHelper.sharedInstance.popularLanguages()
    var enableSettings : Bool = false
    
    
    //let moreIconColor = standardColor
    let moreIconColor = UIColor.lightGray
    let backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    
    var profileNameLabel : String = ""
    var profileCommentLabel : String = ""
    var userResults : Results<User>!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("MoreTableViewControllerIB viewDidLoad")
        self.tableView?.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        
        //dont show empy cells at bottom
        self.tableView?.tableFooterView = UIView()
        // default TableView section header background color on the iPhone
        self.tableView?.backgroundColor = backgroundColor
        
       userResults = RealmHelper.sharedInstance.realm.objects(User.self)
        
        profileNameLabel = userResults[0].signupUsername
        profileCommentLabel = userResults[0].signupEmail
        
        userResults = RealmHelper.sharedInstance.realm.objects(User.self)
        
        print(userResults)
  


        
    }
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Profile Cell
        if      section == 0 {
            return 1
        }
        // stats, settings, help
        else if section == 1 {
            return 3
        }
        //log out
        /*
        else if section == 2 {
            return 1
        }
        */
        
        // has to return something
        else {
            return 1
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 5) {
            return "Film Information"
        } else {
            return " "
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //hide first section header
        if(section == 0){
            return 0.0
        }
        else{
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        returnedView.backgroundColor = backgroundColor
        
        let label = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
        label.text = " "
        label.textColor = .black
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            if indexPath.row == 0 {
                print("test if indexPath.row == 0")
                                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
                
                cell.profileCommentLabel.text = profileCommentLabel
                cell.profileNameLabel.text = profileNameLabel
                // cell.profilePictureView.image = #imageLiteral(resourceName: "test_profile_image")
                cell.profilePictureView.image = #imageLiteral(resourceName: "generic_profile_picture_outline")
                
                // TEST REMOVE
                cell.profilePictureView.image = {()->UIImage in
                    var FBuserImage : UIImage
                    FBuserImage = #imageLiteral(resourceName: "generic_profile_picture_outline")
                    var FBuserID : String = ""
                    FBuserID = "1796747415" //test tims facebook ID
                    let facebookProfileUrl = "http://graph.facebook.com/\(FBuserID)/picture?type=large"
                    
                    let url = URL(string: facebookProfileUrl)
                    
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        if data != nil {
                            print("sucessfully got data from FB image")
                        }else{
                            print("FB image download failed.")
                        }
                        DispatchQueue.main.async {
                            FBuserImage = UIImage(data: data!)!
                            print("Image from Facebook set!")
                        }
                    }
                    return FBuserImage
                }()
                
                // round mask around profilePictureView
                cell.profilePictureView.layer.borderWidth = 1
                cell.profilePictureView.layer.masksToBounds = false
                cell.profilePictureView.layer.borderColor = UIColor.black.cgColor
                cell.profilePictureView.layer.cornerRadius = cell.profilePictureView.frame.height/2
                cell.profilePictureView.clipsToBounds = true
                cell.selectionStyle = UITableViewCellSelectionStyle.none

                
                return cell
            }
        }
            
        // SECTION 1
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell") ?? UITableViewCell(style: .default, reuseIdentifier: "statisticsCell")
                
                // display chevron
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                cell.textLabel?.text = "Statistics"
                cell.imageView?.image = #imageLiteral(resourceName: "statistics")
                cell.imageView?.image = cell.imageView?.image!.withRenderingMode(.alwaysTemplate)
                //cell.imageView?.tintColor = UIColor.black
                cell.imageView?.tintColor = moreIconColor
                cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
                
                
                
                return cell
                
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") ?? UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
                
                // display chevron
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                cell.textLabel?.text = "Settings"
                cell.imageView?.image = #imageLiteral(resourceName: "settings_iphone_25")
                cell.imageView?.image = cell.imageView?.image!.withRenderingMode(.alwaysTemplate)
                //cell.imageView?.tintColor =       wq
                cell.imageView?.tintColor = moreIconColor
                //cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit // changes nothing??
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "helpCell") ?? UITableViewCell(style: .default, reuseIdentifier: "helpCell")
                
                // display chevron
                
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                cell.textLabel?.text = "Help"
                
                cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit //test
                cell.imageView?.image = #imageLiteral(resourceName: "help_icon_question_mark_custom_inv_25")
                cell.imageView?.image = cell.imageView?.image!.withRenderingMode(.alwaysTemplate)
                //cell.imageView?.tintColor = UIColor.black
                cell.imageView?.tintColor = moreIconColor
                //cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit // changes nothing??
                return cell
                
            }
        
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell") ?? UITableViewCell(style: .default, reuseIdentifier: "logoutCell")
                
                // NO CHEVRON FOR LOG OUT
                //cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                // CENTER TEXT ONLY FOR LOG OUT
                cell.textLabel?.textAlignment = .center
                
                cell.textLabel?.text = "Log out"
        
                
                return cell
            }

        }
            

        
       
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
            return cell

       // }
    }
    
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select")
        
        if indexPath.section == 1 {
            // statistics selected
            if       indexPath.row == 0 {
                let statisticsController = StatisticsController()
                self.navigationController?.pushViewController(statisticsController, animated: true)
            }
            // Settings selected
            else  if indexPath.row == 1 {
                
                
            SVProgressHUD.showError(withStatus: "Coming Soon!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    SVProgressHUD.dismiss()
            }
                
            }
            else  if indexPath.row == 2 {
                print("Select sect 1 indexPath 2: help")

                let moreHelpView = MoreHelpView()
                self.navigationController?.pushViewController(moreHelpView, animated: true)
            }
        }
        // logout pressed
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                logoutCellPressed()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //hide first section header
        if(indexPath.section == 0){
            return 192
        }
        else{
            return UITableViewAutomaticDimension // 44
        }
       
    }
    
    func logoutCellPressed(){
        
        //let user = SyncUser.all.first
        //user.logOut()
        
        SyncUser.current!.logOut()
        
        
        // SignupController.logOutFromSettings()
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.swapRootViewControllerWithAnimation(newViewController: StyleableNavigationController.init(rootViewController:LaunchController()), animationType: .Push)
    }
    
}
