//
//  RegisterViewController.swift
//  Selfie
//
//  Created by Mac Bellingrath on 10/26/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit




class RegisterViewController: LoginViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        
        didSet {
            avatarImageView.userInteractionEnabled = true
        }
    }
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var tapGR: UITapGestureRecognizer!
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        
        guard let fn = firstNameTextField.text, let ln = lastNameTextField.text, let pw = passwordTextField.text, let em = emailTextField.text where [fn, ln, pw, em]>* else { return }
        
        NetworkManager.sharedManager().signUp(fn, lastName: ln, email: em, password: pw) { (success, statusCode) -> () in
            
            
            if success == true {
                
                if let img = self.avatarImageView.image {
                
                    NetworkManager.sharedManager().uploadPhoto2(img, completion: { (success) -> () in
                        print("image: \(img)")
                    
                        if success {
                        self.performSegueWithIdentifier("SignUpComplete", sender: self)
                        }
                            })
                        } else {
                    print("Could not get image")
                }
    
             } else {
                
                self.alertUser("Sign Up Failed", message: String(statusCode))
            }
            
        }

        

    }
    
    func setPhoto(sender: UITapGestureRecognizer) {
        print("Tapped")
        //Presents Image Picker
        self.navigationController?.presentViewController(picker, animated: true, completion: nil)

    }
    
    lazy var picker: UIImagePickerController = {
        let lazyPicker = UIImagePickerController()
        lazyPicker.delegate = self
        lazyPicker.sourceType = UIImagePickerControllerSourceType.Camera
        lazyPicker.showsCameraControls = true
        lazyPicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
        return lazyPicker }()

    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tapGR = UITapGestureRecognizer(target: self, action: "setPhoto:")
        
        avatarImageView.addGestureRecognizer(tapGR)
//
        
        

        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - IMAGE PICKER
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.avatarImageView.image = image
            dismissViewControllerAnimated(true, completion: nil)
            
        }
    }


   
}
