//
//  LoginViewController.swift
//  Selfie
//
//  Created by Mac Bellingrath on 10/26/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBAction func  loginButtonPressed(sender: UIButton) {
        logIn()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
//        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        
        

        // Do any additional setup after loading the view.
    }
    

    
    func logIn(){
        
        guard let email = userNameTextField.text, let password = passwordTextfield.text else { return }
        
        NetworkManager.sharedManager().login(email, password: password) { [weak self] (success) -> () in
            if success {  self?.performSegueWithIdentifier("ShowMain", sender: self)
            } else {
                self?.alertUser("Sorry, We couldn't log you in.", message: "Please try again.")
            }
        }
    }

}
    




        

    
        



