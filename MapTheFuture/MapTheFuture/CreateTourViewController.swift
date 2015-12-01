//
//  CreateTourViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 12/1/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

class CreateTourViewController: UIViewController {

    
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tourTitleTextField: UITextField!
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        guard let title = tourTitleTextField.text where [title]>* else { return }
        NetworkManager.sharedManager().createTour(title) { [unowned self] (success) -> () in
            if success == false {
                self.alertUser("Couldn't create tour", message: "Something went wrong when creating this tour. Try again")
            } else {
                self.alertUser("Success", message: "We have created \(title)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.hidden = true
      
    }


    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doneButton.hidden = false
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
