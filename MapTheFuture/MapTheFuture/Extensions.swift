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
import AlamofireImage


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


public extension SequenceType {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    
    func categorize<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            dict[key]?.append(el) ?? {dict[key] = [el]}()
        }
        
        return dict
    }
}


let distanceStrings = ["Less than one mile", "One to five miles", "Five to ten miles", "Ten to twenty miles","Twenty to fifty miles", "Far Away", "Unknown"]
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
    
    
        func titleFromDouble() -> String {
            
            
            let miles = (round(1000 * (self * 0.000621371)) / 1000)
            switch miles {
            case let x where x > 0 && x <= 1 : return "Less than one mile"
            case let x where x > 1 && x <= 5 : return "One to five miles"
            case let x where x > 5 && x <= 10: return "Five to ten miles"
            case let x where x > 10 && x <= 20: return "Ten to twenty miles"
            case let x where x > 20 && x <= 50: return "Twenty to fifty miles"
            case let x where x > 50: return "Far Away"
            default: return "Unknown"
                
            }
        }
    

}
extension MKMapView {
    
    func setMap() {
        
        var zoomRect: MKMapRect?
        
        for annotation in self.annotations {
            
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            
            let annotationRect = MKMapRect(origin: annotationPoint, size: MKMapSize(width: 0.1, height: 0.1))
            
            if zoomRect == nil {
                
                zoomRect = annotationRect
                
            } else {
                
                zoomRect = MKMapRectUnion(zoomRect!, annotationRect)
            }
            if let _rect = zoomRect {
                self.setVisibleMapRect(_rect, animated: true)
            }
        }
        
    }
    
    func setMap(withCender: CLLocationCoordinate2D, radius: Double) {
        
        var zoomRect: MKMapRect?
        
        for annotation in self.annotations {
            
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            
            let annotationRect = MKMapRect(origin: annotationPoint, size: MKMapSize(width: 0.1, height: 0.1))
            
            if zoomRect == nil {
                
                zoomRect = annotationRect
                
            } else {
                
                zoomRect = MKMapRectUnion(zoomRect!, annotationRect)
            }
            if let _rect = zoomRect {
                self.setVisibleMapRect(_rect, animated: true)
            }
        }
        
    }


}


extension UINavigationController {
    
    func dismiss(sender: UIButton) {
        
    }
    func displayBlur(withView: UIView) {
        
        //1
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.clearColor()
        
        let effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        
        let visualEfView = UIVisualEffectView(effect: effect)
        visualEfView.frame = UIScreen.mainScreen().bounds
        
        visualEfView.contentView.addSubview(withView)
        withView.frame = CGRect(x: 0, y: 0, width: visualEfView.frame.width / 2 , height: visualEfView.frame.height / 2)
        withView.center = visualEfView.contentView.center
        
        //3
        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: withView.frame.width, height: 30))
        doneButton.backgroundColor = UIColor.unitedNationsBlue()
        
        doneButton.titleLabel?.textColor = UIColor.whiteColor()
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
        
        doneButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
        
        
        
        
        
        doneButton.center = CGPoint(x: visualEfView.center.x, y: withView.frame.minY - CGFloat(doneButton.frame.height * 2))
        
        visualEfView.contentView.addSubview(doneButton)
        
        viewController.view.addSubview(visualEfView)
        self.presentViewController(viewController, animated: true, completion: nil)
        
//        UIApplication.sharedApplication().keyWindow?.addSubview(visualEfView)
        
        
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