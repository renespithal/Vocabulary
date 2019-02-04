//
//  StyleableSearchController.swift
//  Vocabulary
//
//  Created by Alex on 26.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit

class StyleableSearchController: UISearchController {
    override func viewDidLoad() {
        super.viewDidLoad()
        apply(currentStyle)
    }
    
    // MARK: - Applying styles
    
    private struct Style {
        let backgroundColor: UIColor
        
        static let light = Style(
            backgroundColor: tabBarBackgroundColor
        )
        
        static let dark = Style(
            backgroundColor: tabBarBackgroundColorDark
        )
    }
    
    private var currentStyle: Style {
        return useDarkMode ? .dark : .light
    }
    
    fileprivate var useDarkMode = false {
        didSet { apply(currentStyle) }
    }
    
    private func apply(_ style: Style) {
        view.backgroundColor = style.backgroundColor
    }
    
}

extension StyleableSearchController: GagatStyleable {
    func toggleActiveStyle() {
        useDarkMode = !useDarkMode
    }
}
