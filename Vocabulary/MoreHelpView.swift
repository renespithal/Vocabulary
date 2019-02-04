//
//  MoreHelpView.swift
//  Vocabulary
//
//  Created by Tim Kraus on 25.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import TBEmptyDataSet


class MoreHelpView: StyleableViewController {
    
    
    var MoreHelpWebView: UIWebView!
 
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        MoreHelpWebView = UIWebView(frame: UIScreen.main.bounds)
        MoreHelpWebView.delegate = self as? UIWebViewDelegate
        view.addSubview(MoreHelpWebView)
        
        
        let HelpURL = URL(string: "http://www.tmkr.de/MI/iOS_Praktikum/Help.html")

        let HelpURLReques = URLRequest(url: HelpURL!)
        MoreHelpWebView.loadRequest(HelpURLReques)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

