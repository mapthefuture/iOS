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