//
//  AvatarViewController.swift
//  Selfie
//
//  Created by Mac Bellingrath on 10/26/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import KeychainSwift


class AvatarViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    var tours: [Tour] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userNameLabel: UILabel! {
        didSet {
            userNameLabel.text = KeychainSwift().get("name")
        }
    }
    
    
    lazy var picker: UIImagePickerController = {
        let lazyPicker = UIImagePickerController()
            lazyPicker.delegate = self
            lazyPicker.sourceType = UIImagePickerControllerSourceType.Camera
            lazyPicker.showsCameraControls = true
            lazyPicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
        return lazyPicker }()
    
    
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            
            
            let gr = UITapGestureRecognizer(target: self, action: "pickPhoto")
            gr.numberOfTapsRequired = 2
            avatarImageView.addGestureRecognizer(gr)
            avatarImageView.getProfilePicture()
            
        }
    }
    

        
        func pickPhoto() {
        //Presents Image Picker
        self.navigationController?.presentViewController(picker, animated: true, completion: nil)
        }

    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        User.logOut()
        self.performSegueWithIdentifier("ShowUserFlow", sender: self)


    }
    
    
    
    
    //MARK: - IMAGE PICKER
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let data = UIImagePNGRepresentation(image) {
            self.avatarImageView.image = image
            
            let keychain = KeychainSwift()
            keychain.set(data, forKey: "profileImage")
            
            dismissViewControllerAnimated(true, completion: nil)
            
            //TO DO
            NetworkManager.sharedManager().uploadPhoto(image, completion: { [weak self] (success) -> () in
                if success {
                    print("success")
                }
                else if success == false {
                    self?.alertUser("Error", message: "Couldn't upload photo")
                }
            })
        }
    }
    
    override func viewDidLoad() {
        NetworkManager.sharedManager().getAllTours { (success, tours) -> () in
            self.tours = tours.filter{$0.user_id == User.currentUserID  }
        }
        
    }
    
    //MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let tour = tours[indexPath.row]
        cell.textLabel?.text = tour.title
        
        return cell
    }

   }
