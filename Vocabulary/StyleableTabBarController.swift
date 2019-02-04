//
//  StyleableTabBarController.swift
//  Vocabulary
//
//  Created by Alex on 19/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class StyleableTabBarController: ESTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        apply(currentStyle)
    }
    
    // MARK: - Applying styles
    
    private struct Style {
        let backgroundColor: UIColor
        let barTintColor: UIColor

        static let light = Style(
            backgroundColor: tabBarBackgroundColor,
            barTintColor: tabBarTintColor
        )
        
        static let dark = Style(
            backgroundColor: tabBarBackgroundColorDark,
            barTintColor: tabBarTintColorDark
        )
    }
    
    private var currentStyle: Style {
        return useDarkMode ? .dark : .light
    }
    
    fileprivate var useDarkMode = false {
        didSet { apply(currentStyle) }
    }
    
    private func apply(_ style: Style) {
        tabBar.backgroundColor = style.backgroundColor
        tabBar.tintColor = style.barTintColor
    }
    
}

extension StyleableTabBarController: GagatStyleable {
    func toggleActiveStyle() {
        useDarkMode = !useDarkMode
    }
}
