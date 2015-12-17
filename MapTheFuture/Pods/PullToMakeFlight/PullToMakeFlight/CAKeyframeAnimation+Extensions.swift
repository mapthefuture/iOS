//
//  Created by Anastasiya Gorban on 4/20/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToMakeFlight
//

import CoreGraphics

enum AnimationType: String {
    case Rotation = "transform.rotation.z"
    case Opacity = "opacity"
    case TranslationX = "transform.translation.x"
    case TranslationY = "transform.translation.y"
    case Position = "position"
    case PositionY = "position.y"
    case ScaleX = "transform.scale.x"
    case ScaleY = "transform.scale.y"
}

enum TimingFunction {
    case Linear, EaseIn, EaseOut, EaseInEaseOut
}

func mediaTimingFunction(function: TimingFunction) -> CAMediaTimingFunction {
    switch function {
    case .Linear: return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    case .EaseIn: return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    case .EaseOut: return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    case .EaseInEaseOut: return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    }
}


extension CAKeyframeAnimation {
    class func animationWith(
        type: AnimationType,
        values:[AnyObject],
        keyTimes:[Double],
        duration: Double,
        beginTime: Double,
        timingFunctions: [TimingFunction] = [TimingFunction.Linear]) -> CAKeyframeAnimation {
                        
        let animation = CAKeyframeAnimation(keyPath: type.rawValue)
        animation.values = values
        animation.keyTimes = keyTimes
        animation.duration = duration
        animation.beginTime = beginTime
        animation.timingFunctions = timingFunctions.map { timingFunction in
            return mediaTimingFunction(timingFunction)
        }
            
        return animation
    }
    
    class func animationPosition(path: CGPath, duration: Double, timingFunction: TimingFunction, beginTime: Double) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path
        animation.duration = duration
        animation.beginTime = beginTime
        animation.timingFunction = mediaTimingFunction(timingFunction)
        return animation
    }
}

extension UIView {
    func addAnimation(animation: CAKeyframeAnimation) {
        layer.addAnimation(animation, forKey: description + animation.keyPath!)
        layer.speed = 0
    }
    
    func removeAllAnimations() {
        layer.removeAllAnimations()
    }
}
