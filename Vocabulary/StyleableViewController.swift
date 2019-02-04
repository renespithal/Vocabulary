//
//  StyleableViewController.swift
//  Vocabulary
//
//  Created by Alex on 19/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit

class StyleableViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        apply(currentStyle)
    }
    
    // MARK: - Applying styles
    
    private struct Style {
        let backgroundColor: UIColor
        
        static let light = Style(
            backgroundColor: viewBackgroundColor
        )
        
        static let dark = Style(
            backgroundColor: viewBackgroundColorDark
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

extension StyleableViewController: GagatStyleable {
    func toggleActiveStyle() {
        useDarkMode = !useDarkMode
    }
}
