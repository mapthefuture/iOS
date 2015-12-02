//
//  AvatarViewController.swift
//  Selfie
//
//  Created by Mac Bellingrath on 10/26/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit


class AvatarViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    lazy var picker: UIImagePickerController = {
        let lazyPicker = UIImagePickerController()
            lazyPicker.delegate = self
            lazyPicker.sourceType = UIImagePickerControllerSourceType.Camera
            lazyPicker.showsCameraControls = true
            lazyPicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
        return lazyPicker }()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBAction func setPhotoButtonPressed(sender: AnyObject) {
        
        //Presents Image Picker
        self.navigationController?.presentViewController(picker, animated: true, completion: nil)

    }
    @IBAction func logoutButtonPressed(sender: UIButton) {
        print("User logged out")
      
        //set token to nil
        
        //segue back to login/register vc
        
        let usersb = UIStoryboard(name: "User", bundle: nil )
        if let nav = usersb.instantiateInitialViewController() as? UINavigationController {
        
        UIApplication.sharedApplication().windows.first?.rootViewController = nav
        
        
        }
    }
    
    //MARK: - IMAGE PICKER
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.avatarImageView.image = image
            dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
     }

   }
