//
//  Extensions.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/25/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



/**
*  Checks collection of strings for any element with character count <= 0
*/
postfix operator >* { }

postfix func >*(xs: [String]) -> Bool {
    
    let rs = xs.map{ $0.characters.count > 0 }
    
    if rs.contains(false) { return false }
    
    return true
}


extension UIViewController {
    
    func alertUser(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }
}

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths.first
    return documentsDirectory ?? ""
}

//MARK: Time

func stringFromTimeInterval(interval: NSTimeInterval) -> String {
    let interval = Int(interval)
    let minutes = (interval / 60) % 60
    let hours = (interval / 3600)
    return String(format: "%02d:%02d", hours, minutes)
}

// UINavigationController

extension UINavigationController {
    func setTitleView() {
        //Create TitleView
        if let image = UIImage(named: "compass") {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
            imageView.contentMode = .ScaleAspectFit
            
            // set the text view to the image view
            self.navigationItem.titleView = imageView
        }

    }
}

//Colors

extension UIColor {
    
    class func armadilloColor() -> UIColor {
       return UIColor(hue:0, saturation:0, brightness:0.29, alpha:1)
    }
    
    class func unitedNationsBlue() -> UIColor {
        return UIColor(hue:0.62, saturation:0.65, brightness:0.91, alpha:1)
    }
    
    class func cinnabarColor() -> UIColor {
        return UIColor(hue:0.02, saturation:0.77, brightness:0.94, alpha:1)
    
    }
    
    class func loblollyColor() ->  UIColor {
        return UIColor(hue:0.59, saturation:0.09, brightness:0.84, alpha:1)
    }
    
    
}



//Distance Conversions
extension Double {
func metersToMiles() -> Double {
    let miles = (round(1000 * (self * 0.000621371)) / 1000)
    return miles
}
}