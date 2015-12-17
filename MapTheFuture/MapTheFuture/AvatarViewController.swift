//
//  AvatarViewController.swift
//  Selfie
//
//  Created by Mac Bellingrath on 10/26/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import KeychainSwift
import AlamofireImage



class AvatarViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    
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
            
            if let avURL = KeychainSwift().get("avatarURL"), let _url = NSURL(string: avURL) {
                let filter = AspectScaledToFillSizeCircleFilter(size: avatarImageView.frame.size)
                avatarImageView.af_setImageWithURL(_url, placeholderImage: UIImage(named: "placeholder"), filter: filter , imageTransition: .CrossDissolve(0.1))
            }
            
            let gr = UITapGestureRecognizer(target: self, action: "pickPhoto:")
            gr.numberOfTapsRequired = 2
            gr.delegate = self
            avatarImageView.addGestureRecognizer(gr)
            
            
        }
    }
    

        
    func pickPhoto(sender: UITapGestureRecognizer) {
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
       
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, ip) -> Void in
            print(ip)
            
            if let t = self.tours[safe: indexPath.row] {
                
//            delete tour here
                NetworkManager.sharedManager().deleteTour(t, success: { (success) -> () in
                    if !(success) {
                        self.alertUser("Error deleting tour", message: "please try again.")
                    } else if success {
                        self.alertUser("Deleted Tour", message: "We have deleted your tour successfully.")
                        self.tableView.reloadData()
                    }
                })
                
            }
        }
        
        
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit", handler: { (editaction, ip) -> Void in
            print("editing \(ip)")
            self.tour = self.tours[indexPath.row]
        
            editaction.backgroundColor = UIColor.loblollyColor()
            
            self.performSegueWithIdentifier("EditSegueIdentifier", sender: self)
          
            
            
        })
        
        
        return [deleteAction, editAction]
    }
    var tour: Tour?
    
 
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let tour = tours[indexPath.row]
        cell.textLabel?.text = tour.title
        
        return cell
    }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "EditSegueIdentifier"  else { return }
        guard let destVC = segue.destinationViewController as? TourEditingViewController else { return }
        
        destVC.tour = self.tour
        }
   }

