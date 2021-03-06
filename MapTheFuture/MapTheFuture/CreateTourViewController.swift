//
//  CreateTourViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 12/1/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import STPopup

class CreateTourViewController: UIViewController, CreateDelegate {
    
    var tour: Tour?
    
    var categoryPickerView: UIVisualEffectView?

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var tourDescriptionTExt: UILabel!
    
    
    @IBOutlet weak var tapToSelectCategoryButton: UIButton!
    @IBOutlet weak var tourCategoryLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tourTitleTextField: UITextField!
 
   
    
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        guard let title = tourTitleTextField.text, var category = tourCategoryLabel.text, let tourdescrip = tour?.description where [title]>* else { return }
        
        if category == "Category" { category = "Other" }
        
        NetworkManager.sharedManager().createTour(title, description: tourdescrip, category: category) {
            
            [weak self] (success, tour) -> () in
            
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
        tapToSelectCategoryButton.layer.cornerRadius = tapToSelectCategoryButton.frame.height / 2
        navigationController?.setTitleView()
//      scrollV.scrollRectToVisible(tourTitleTextField.frame, animated: true)
        
      
    }


    @IBOutlet weak var stackView: UIStackView!

    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        if tourTitleTextField.text?.characters.count > 0 {
            doneButton.backgroundColor = UIColor.unitedNationsBlue()
            let atr = NSAttributedString(string: "Done", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCallout) ])
            doneButton.setAttributedTitle(atr, forState: .Normal)
            doneButton.titleLabel?.textAlignment = .Center
         
            
        }
        
            view.updateConstraintsIfNeeded()
        
        
        return true
    }
    

    
    @IBOutlet weak var descriptionButton: UIButton! {
        didSet {
            descriptionButton.layer.cornerRadius = descriptionButton.frame.height / 2
        }
    }
    

    @IBAction func pressedDescriptionButton(sender: AnyObject) {
        
        view.resignFirstResponder()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let popupVC = sb.instantiateViewControllerWithIdentifier("CreatePopUpVC") as? CreatePopupViewController{
        
            popupVC.delegate = self
            
            let pop = STPopupController(rootViewController: popupVC)
            pop.cornerRadius = 4

            pop.presentInViewController(self)


        }
        
    }
    
    //Delegate
    func didWriteDescription(description: String) {
        self.tour?.description = description
        
        tourDescriptionTExt.text = description
        print(description)
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
        tourCategoryLabel.text = Tour.categories[row] ?? "Category"
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

//extension CreateTourViewController: UITextViewDelegate {
//    
//    func textViewShouldEndEditing(textView: UITextView) -> Bool {
//        return true
//    }
//    
//    func textViewDidBeginEditing(textView: UITextView) {
//        textView.text = ""
//    }
//
//    func textViewDidEndEditing(textView: UITextView) {
//        let description = textView.text
//        tourDescriptionTextField.text = description
//        tour?.description = description
//        textView.resignFirstResponder()
//    }
//    
//}



