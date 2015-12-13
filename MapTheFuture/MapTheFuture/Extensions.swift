//
//  Extensions.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/25/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit
import KeychainSwift

protocol MapItemLiteralConvertible {
    
    func toSite() -> Site
}


func calculateTotalDistanceFrom(routes: [MKRoute]) -> Double {
    let total = routes.reduce(0){$0.0 + $0.1.distance}
    print("Routes Total Distance: \(total.metersToMilesString())")
    return total
}

func calculateTimeEstimateStringFrom(routes: [MKRoute]) -> String {
    
    for r in routes { print(r.expectedTravelTime) }
    
    let total = routes.reduce (0) { $0.0 + $0.1.expectedTravelTime}
    print("Routes Total travel time: \(total)")
    return total.stringFromTimeInterval()
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

infix operator ^= { }
func ^=(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
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
//    let interval = Int(self)
    let minutes = Int((self / 60))
    let hours = Int(self / 3600)
    return String(format: "%02d:%02d", hours, minutes)
    }
}

// UINavigationController

extension UIViewController {
    func setTitleView() {
        //Create TitleView
        if let image = UIImage(named: "compass") {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            
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

extension UIImageView {

    func getProfilePicture(){
        let keychain = KeychainSwift()
    if let data = keychain.getData("profileImage"), let image = UIImage(data: data) {
        
        self.image = image

        
    } else {
        
        NetworkManager.sharedManager().downloadProfileImage { [weak self] (success, profileImage) -> () in
            if let prof = profileImage {
                self?.image = prof
                self?.contentMode = .ScaleAspectFill
                if let imgD = UIImagePNGRepresentation(prof) {
                    keychain.set(imgD, forKey: "profileImage")
                }
            }
        }
    }
}
}