//
//  Loading.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/10/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//
import UIKit
class Loading {
    static let backgroundColor = UIColor(white: 1.0, alpha: 0.1)
    static let fade = 0.1
    
    static var indicator: UIView = {
        var view = UIView()
        let screen: CGRect = UIScreen.mainScreen().bounds
        var side = screen.width / 4
        var x = (screen.width / 2) - (side / 2)
        var y = (screen.height / 2) - (side / 2)
        view.frame = CGRect(x: x, y: y, width: side, height: side)
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = 10
        view.alpha = 0.0
        view.tag = 1
        if let image = UIImage(named: "spinner") {
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: side / 4, y: side / 4, width: side / 2, height: side / 2)
        view.addSubview(imageView)
        }
        return view
    }()
    
    static var animation: CABasicAnimation = {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 2.0
        rotateAnimation.repeatCount = Float.infinity
        return rotateAnimation
    }()
    
    static func start () {
        if let window :UIWindow = UIApplication.sharedApplication().keyWindow {
            var found: Bool = false
            for subview in window.subviews {
                if subview.tag == 1 {
                    found = true
                }
            }
            if !found {
                for subview in indicator.subviews {
                    subview.layer.addAnimation(animation, forKey: nil)
                }
                window.addSubview(indicator)
                UIView.animateWithDuration(fade, animations: {
                    self.indicator.alpha = 1.0
                })
            }
        }
    }
    
    static func stop () {
        UIView.animateWithDuration(fade, animations: {
            self.indicator.alpha = 0.0
            }, completion: { (value: Bool) in
                self.indicator.removeFromSuperview()
                for subview in self.indicator.subviews {
                    subview.layer.removeAllAnimations()
                }
        })
    }
}