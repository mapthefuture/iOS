//
//  StepsTableViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/30/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit

class StepsTableViewController: UITableViewController {
    
    var route: MKRoute? {
        didSet {
            print("route set \(route)")
    
        }
    }
    
    var routes: [MKRoute]?
    
    @IBOutlet weak var timeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let eta = route?.expectedTravelTime {
            timeLabel.text = stringFromTimeInterval(eta)
            
        }


    }

    

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return route?.steps.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = route?.steps[indexPath.row].instructions
        cell.detailTextLabel?.text = String(route?.steps[indexPath.row].distance)
        
        

        return cell
    }


   }
