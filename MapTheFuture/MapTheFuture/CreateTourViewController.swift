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
    
    var categoryPickerView: UIVisualEffectView?

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tourTitleTextField: UITextField!
    @IBOutlet weak var tourCategoryTextField: UITextField!
    @IBOutlet weak var tourDescriptionTextField: UITextField!
    @IBAction func doneButtonPressed(sender: AnyObject) {
        guard let title = tourTitleTextField.text, let category = tourCategoryTextField.text, let tourdescrip = tourDescriptionTextField.text where [title]>* else { return }
        NetworkManager.sharedManager().createTour(title, description: tourdescrip, category: category) { [weak self] (success, tour) -> () in
            if !success  {
                self?.alertUser("Couldn't create tour", message: "Something went wrong when creating this tour. Try again")
            } else if success {
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

extension CreateTourViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBAction func pressedCategoryButton(sender: AnyObject) {
        
        
        
        //1
        let effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)

        let visualEfView = UIVisualEffectView(effect: effect)
        visualEfView.frame = UIScreen.mainScreen().bounds
       
        //2
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: visualEfView.frame.width - 50 , height: visualEfView.frame.height - 40))
    
        picker.delegate = self
        picker.dataSource = self
        
        visualEfView.contentView.addSubview(picker)
        picker.center = visualEfView.center
        
        //3 
        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: picker.frame.width, height: 30))
        doneButton.backgroundColor = UIColor.unitedNationsBlue()

        doneButton.titleLabel?.textColor = UIColor.whiteColor()
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
        
        doneButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
        
        
  
        
        
        doneButton.center = CGPoint(x: visualEfView.center.x, y: picker.frame.maxY - CGFloat(20))
        
        visualEfView.contentView.addSubview(doneButton)
        categoryPickerView = visualEfView
        
       
        UIApplication.sharedApplication().keyWindow?.addSubview(visualEfView)

        
    }
    
    func dismiss(sender: UIButton) {
        
        guard let vev = categoryPickerView else { return }
        
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseOut,
            
            animations: {
            
                vev.alpha = 0
            
                self.categoryPickerView = nil
            
            }, completion: nil  )
        
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Tour.categories.count
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
         print(row, component)
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let title = Tour.categories[row]
        
        let attributes = [
            NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        let atrstring = NSAttributedString(string: title, attributes: attributes)
        
        return atrstring
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return  "Title"
    }
    
    
}


