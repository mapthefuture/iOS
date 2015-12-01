//
//  ProfileViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 12/1/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var usersTours: [Tour] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.sharedManager().getAllTours { [unowned self] (success, tours) -> () in
            if success == true {
                
         
                //TODO - Filter based on current user's id
                
                let myTours = tours.filter{$0.user_id != nil }
                self.usersTours = myTours
            }
        }
    imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true

   
    }
    
    
    
    //MARK: - Table View
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let tour = usersTours[indexPath.row]
        cell.textLabel?.text = tour.title
        cell.detailTextLabel?.text = "User ID: \(tour.user_id)"
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersTours.count
    }

}
