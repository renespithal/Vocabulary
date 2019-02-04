//
//  MiddleButtonView.swift
//  Vocabulary
//
//  Created by Alex on 26/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit

class MiddleButtonView: BasicContentView {
    
    override func highlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("small", context: nil)
        UIView.setAnimationDuration(0.01)
        backdropColor =  tabBarMiddleButtonColorHighlighted
        UIView.commitAnimations()
        completion?()
    }
    
    override func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("big", context: nil)
        UIView.setAnimationDuration(0.1)
        backdropColor = tabBarMiddleButtonColor
        UIView.commitAnimations()
        completion?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
