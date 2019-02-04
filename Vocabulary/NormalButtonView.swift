//
//  NormalButtonView.swift
//  Vocabulary
//
//  Created by Alex on 26/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit

class NormalButtonView: BasicContentView {
    var firstSelectAnimation = false
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        if firstSelectAnimation {
            firstSelectAnimation = false
        } else {
            self.bounceAnimation()
        }
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        //self.bounceAnimation()
        completion?()
    }
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}
