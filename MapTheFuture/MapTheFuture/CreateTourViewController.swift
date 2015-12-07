//
//  CreateTourViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 12/1/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

class CreateTourViewController: UIViewController {
    
    var tour: Tour?

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tourTitleTextField: UITextField!
    
    @IBOutlet weak var tourCategoryTextField: UITextField!
    
    @IBOutlet weak var tourDescriptionTextField: UITextField!
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        guard let title = tourTitleTextField.text, let category = tourCategoryTextField.text, let tourdescrip = tourDescriptionTextField.text where [title]>* else { return }
        NetworkManager.sharedManager().createTour(title, description: tourdescrip, category: category) { [weak self] (success, tour) -> () in
            if success == false {
                self?.alertUser("Couldn't create tour", message: "Something went wrong when creating this tour. Try again")
            } else if success == true {
                if let _tour = tour {
                    self?.tour = _tour
                    self?.performSegueWithIdentifier("AddSites", sender: self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.hidden = true
        navigationController?.setTitleView()
      
    }


    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == tourTitleTextField {
            tourCategoryTextField.becomeFirstResponder()
            
        } else if textField == tourCategoryTextField {
            tourDescriptionTextField.becomeFirstResponder()
        } else{
            textField.resignFirstResponder()
            doneButton.hidden = false
        }
        
        
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            guard segue.identifier == "AddSites" else { return }
            guard let addSitesVC = segue.destinationViewController as? AddSitesViewController else { return }
            addSitesVC.tour = self.tour
        
                
            
    }
}


