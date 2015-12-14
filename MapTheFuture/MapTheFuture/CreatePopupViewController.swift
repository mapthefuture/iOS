//
//  CreatePopupViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/14/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import STPopup

protocol CreateDelegate: class{
    func didWriteDescription(description: String)
}

class CreatePopupViewController: UIViewController, UITextViewDelegate, CreateDelegate {

   @IBOutlet weak var textV: UITextView!
    
   weak var delegate: CreateDelegate?
    
    func didWriteDescription(description: String) {
        delegate?.didWriteDescription(description)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        delegate?.didWriteDescription(textV.text)
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentSizeInPopup = CGSizeMake(300, 400);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
        // Do any additional setup after loading the view.
    }

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "Create"
        self.contentSizeInPopup = CGSizeMake(300, 400)
        self.landscapeContentSizeInPopup = CGSize(width: 300, height: 400)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Create"
        self.contentSizeInPopup = CGSizeMake(300, 400)
        self.landscapeContentSizeInPopup = CGSize(width: 300, height: 400)
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
    }

    
}
