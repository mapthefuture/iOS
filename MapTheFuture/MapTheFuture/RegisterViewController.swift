//
//  RegisterViewController.swift
//  Selfie
//
//  Created by Mac Bellingrath on 10/26/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit




class RegisterViewController: LoginViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func registerButtonPressed(sender: UIButton) {
//        
//        guard let un = usernameTextField.text, let pw = passwordTextField.text, let em = emailTextField.text where un != "" && pw != "" && em != "" else { print("blank fields"); alertError(message: "Oops..", reason: "All fields are required.") ; return }
//        
//        NetworkManager.sharedManager().register(un, password: pw, email: em) { (success) -> Void in
//            let mainsb = UIStoryboard(name: "Main", bundle: nil)
//            if success {
//                if let tab = mainsb.instantiateInitialViewController() as? UITabBarController
//                {
//                    self.navigationController?.navigationBarHidden = false
//                    self.navigationController?.pushViewController(tab, animated: true)
//                } else  {
//                    self.alertError(message: "Registration Failed.", reason: "Please try again.")
//                    
//                }
//            }
//        }
    }
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

   
}
