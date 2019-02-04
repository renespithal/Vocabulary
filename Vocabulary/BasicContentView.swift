//
//  ExampleBackgroundContentView.swift
//  ESTabBarControllerExample
//
//  Created by lihao on 2017/2/9.
//  Copyright © 2017年 Vincent Li. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class BasicContentView: ESTabBarItemContentView {
    public var duration = 0.2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = .clear
        highlightTextColor = .clear
        iconColor = tabBarTintColor
        highlightIconColor = standardColor
        backdropColor = UIColor.white
        highlightBackdropColor = UIColor.white
    }
    
    public convenience init(specialWithAutoImplies implies: Bool) {
        self.init(frame: CGRect.zero)
        textColor = .clear
        highlightTextColor = .clear
        iconColor = .white
        highlightIconColor = .white
        backdropColor = standardColor
        highlightBackdropColor = standardColor
        if implies {
            let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(BasicContentView.playImpliesAnimation(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .commonModes)
        }
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func playImpliesAnimation(_ sender: AnyObject?) {
        if self.selected == true || self.highlighted == true {
            return
        }
        let view = self.imageView
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.15, 0.8, 1.15]
        impliesAnimation.duration = 0.3
        impliesAnimation.calculationMode = kCAAnimationCubic
        impliesAnimation.isRemovedOnCompletion = true
        view.layer.add(impliesAnimation, forKey: nil)
    }
    

}
