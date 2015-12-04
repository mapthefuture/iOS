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
import OceanView
import KeychainSwift


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,  MKMapViewDelegate, UISearchBarDelegate{
   
   
   var tours: [Tour] = [] {
      didSet {
         print(tours.flatMap{$0.id})
         tableView.reloadData()
      }
   }
   
    @IBOutlet weak var greetingLabel: UILabel!

   var searchController:UISearchController!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func searchButtonPressed(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }

    @IBAction func findMeButtonPressed(sender: AnyObject) {
        LocationManager.sharedManager().requestWhenInUseAuthorization()
        LocationManager.sharedManager().startUpdatingLocation()
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
      
  
      
      
         let keychain = KeychainSwift()
      if let name = keychain.get("name") {
         greetingLabel.text = "Hello, \(name)"
         
      }
      if let data = keychain.getData("profileImage"), let image = UIImage(data: data) {

            imageView.image = image
         }
        
      
      
        
       

      NetworkManager.sharedManager().getAllTours { [weak self] (success, tours) -> () in
         
         if success == false {
            
            self?.alertUser("Failed to get tours", message: "We're having trouble connecting to the network. Try again")
      
         } else {
            
            self?.tours = tours.filter{$0.title != nil }.sort{$0.description?.characters.count > $1.description?.characters.count}
            
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
      if let image = UIImage(named: "compass") {
         let imageView = UIImageView(image: image)
         imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
         
         imageView.contentMode = .ScaleAspectFit
         
         // set the text view to the image view
         self.navigationItem.titleView = imageView
      }

    }
    
    deinit {
      
        LocationManager.sharedManager().stopUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
      print(locations)
        
        guard let loc = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        self.mapView.setRegion(region, animated: true)
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

