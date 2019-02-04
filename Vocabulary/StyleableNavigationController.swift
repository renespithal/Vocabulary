//
//  StyleableNavigationController.swift
//  Gagat
//
//  Created by Tim Andersson on 2017-06-03.
//  Copyright © 2017 Cocoabeans Software. All rights reserved.
//

import UIKit

class StyleableNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apply(currentStyle)
    }

	private struct Style {
		var navBarColor: UIColor
        var navBarTintColor: UIColor
        var navBarTitleColor: UIColor

        
        static let light = Style(
            navBarColor : navigationBarBackgroundColor,
            navBarTintColor : navigationBarTintColor,
            navBarTitleColor : navigationBarTitleColor
        )

		static let dark = Style(
            navBarColor : navigationBarBackgroundColorDark,
            navBarTintColor : navigationBarTintColorDark,
            navBarTitleColor : navigationBarTitleColorDark
		)
	}

	private var currentStyle: Style {
		return useDarkMode ? .dark : .light
	}

	fileprivate var useDarkMode = false {
		didSet { apply(currentStyle) }
	}

	private func apply(_ style: Style) {
        navigationBar.isTranslucent = false
        navigationBar.barStyle = .black
        navigationBar.barTintColor = style.navBarColor
        navigationBar.tintColor = style.navBarTintColor
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: style.navBarTitleColor]
    }

}

extension StyleableNavigationController: GagatStyleable {
	func toggleActiveStyle() {
		useDarkMode = !useDarkMode
		if let styleableChildViewController = topViewController as? GagatStyleable {
			styleableChildViewController.toggleActiveStyle()
		}
	}
}
