//
//  MainViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/18/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import KeychainSwift


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,  MKMapViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
   
   
   var tours: [Tour] = [] {
      didSet {
         print(tours.flatMap{$0.id})
         tableView.reloadData()
      }
   }
   
    @IBOutlet weak var greetingLabel: UILabel!

   var searchController:UISearchController!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            let gr = UITapGestureRecognizer(target: self, action: "userDidTapMapView:")
            gr.delegate = self
            gr.numberOfTapsRequired = 1
            mapView.addGestureRecognizer(gr)
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func searchButtonPressed(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }

    @IBAction func findMeButtonPressed(sender: AnyObject) {
        LocationManager.sharedManager().requestWhenInUseAuthorization()
        LocationManager.sharedManager().startUpdatingLocation()
    }
    
    @IBOutlet weak var upArrow: UIButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()
      LocationManager.sharedManager().requestWhenInUseAuthorization()
      LocationManager.sharedManager().startUpdatingLocation()
      
  
      
      
         let keychain = KeychainSwift()
      if let name = keychain.get("name") {
         greetingLabel.text = "Hello, \(name)"
         
      }
      if let data = keychain.getData("profileImage"), let image = UIImage(data: data) {

            imageView.image = image
         }
      Loading.start()

      NetworkManager.sharedManager().getAllTours { [weak self] (success, tours) -> () in
         
         if success == false {
            
            self?.alertUser("Failed to get tours", message: "We're having trouble connecting to the network. Try again")
      
         } else {
            
            self?.tours = tours.sort{$0.description?.characters.count > $1.description?.characters.count}
            Loading.stop()
            
         }
   
      }
        //Configure ImageView
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
    
      
        //Setup Map
        LocationManager.sharedManager().delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = true
      
      
      //Create TitleView
      setTitleView()
//      if let image = UIImage(named: "iconWhite") {
//         let imageView = UIImageView(image: image)
//         imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//
//         
//         imageView.contentMode = .ScaleAspectFit
//         
//         // set the text view to the image view
//         self.navigationItem.titleView = imageView
//         
//      }

    }
   
   override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
      LocationManager.sharedManager().stopUpdatingLocation()
   }
    
    deinit {
      
        LocationManager.sharedManager().stopUpdatingLocation()
    }
    
    
    //MARK: - Constraints
    @IBOutlet weak var mapToTableRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapToTableRatioExpandedConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewtoTopConstraint: NSLayoutConstraint!
    //
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
      print(locations)
        
        guard let loc = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func userDidTapMapView(sender: UITapGestureRecognizer) {
        
        if mapToTableRatioConstraint.active {
            
      
            NSLayoutConstraint.deactivateConstraints([mapToTableRatioConstraint])
            NSLayoutConstraint.activateConstraints([mapToTableRatioExpandedConstraint])
        
        } else if mapToTableRatioExpandedConstraint.active {

            NSLayoutConstraint.deactivateConstraints([mapToTableRatioExpandedConstraint])
            NSLayoutConstraint.activateConstraints([mapToTableRatioConstraint])
        }
        UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.view.layoutIfNeeded()
            if self.upArrow.hidden == true { self.upArrow.hidden = false } else { self.upArrow.hidden = true }
            if self.imageView.hidden == true { self.imageView.hidden = false } else { self.imageView.hidden = true }
            if self.greetingLabel.hidden == true { self.greetingLabel.hidden = false } else { self.greetingLabel.hidden = true }

            }, completion: nil)
    }
    
    
    //MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MapTableViewCell
      
        let tour = tours[indexPath.row]
      
         cell.tourTitleLabel.text = tour.title ?? ""
         cell.tourDescriptionLabel?.text = tour.description ?? ""
         //TODO - Configure Media Preview
        return cell
    }
   
   func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return 70.0
   }

    //MARK: - MapView
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard segue.identifier == "ShowTourDetail", let siteTVC = segue.destinationViewController as? SiteTableViewController else { return }
      
        guard let selected = tableView.indexPathForSelectedRow?.row else { return }
        let tour = tours[selected]
        siteTVC.tour = tour
    }
}

