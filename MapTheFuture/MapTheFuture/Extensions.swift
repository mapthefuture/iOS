//
//  Extensions.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/25/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit


func calculateTotalDistanceFrom(routes: [MKRoute]) -> Double {
    
    return routes.reduce(0){$0.1.distance}
}

func calculateTimeEstimateStringFrom(routes: [MKRoute]) -> String {
    return routes.reduce(0) {$0.1.expectedTravelTime}.stringFromTimeInterval()
}





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

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

//MARK: Time

extension NSTimeInterval {

func stringFromTimeInterval() -> String {
    let interval = Int(self)
    let minutes = (interval / 60) % 60
    let hours = (interval / 3600)
    return String(format: "%02d:%02d", hours, minutes)
    }
}

// UINavigationController

extension UIViewController {
    func setTitleView() {
        //Create TitleView
        if let image = UIImage(named: "iconWhite") {
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
    
    func metersToMilesString() -> String {
        let miles = (round(1000 * (self * 0.000621371)) / 1000)
    
        switch miles {
        case let x where x == 0:  return "Distance Unknown"
        case let x where x <= 0.25: return "Less than a quarter mile"
        case let x where x <= 0.5:  return "Less than half of a mile"
        case let x where x <= 1.0:  return "Less than a mile"
        case let x where x > 1.0: return "About \(x) miles"
        default: return "Distance Unknown"
            
        }
    }
}