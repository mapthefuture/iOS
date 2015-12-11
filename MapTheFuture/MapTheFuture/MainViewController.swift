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
         
        tours.map({ t in
            guard let coord = t.coordinate else { return }
            let a = MKPointAnnotation()
            a.coordinate = coord
            a.title = t.title
            a.subtitle = t.description
            mapView.addAnnotation(a)
            
         })
         
         tableView.reloadData()
      }
   }
   
   
   var up = false {
      didSet {
        
        imageViewtoTopConstraint.constant = mapToTableRatioConstraint.active ? -100 : 20
            
        upArrow.transform = CGAffineTransformMakeRotation(CGFloat(((up ? -180 : 0) * (M_PI / 180))))
         upArrow.updateConstraintsIfNeeded()
        
        
      }
   }
   
   var tapGR: UITapGestureRecognizer?
   
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            tapGR = UITapGestureRecognizer(target: self, action: "userDidTapMapView:")
            tapGR?.delegate = self
            tapGR?.numberOfTapsRequired = 1
         if let _tapGr = tapGR { mapView.addGestureRecognizer(_tapGr)
         }
        }
    }
   
    var searchController:UISearchController!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!

   
   func refresh() {
     
      
      Loading.start()
      if tours.isEmpty { print(1); toggleView() }
      
      NetworkManager.sharedManager().getAllTours { [weak self] (success, tours) -> () in
         
         if success == false {
            
            self?.alertUser("Failed to get tours", message: "We're having trouble connecting to the network. Try again")
            
         } else {
            
            self?.tours = tours.sort{$0.description?.characters.count > $1.description?.characters.count}
            
            Loading.stop()
            print(2)
            self?.toggleView()
            
         }
      }
   }
   


    @IBAction func findMeButtonPressed(sender: AnyObject) {
        LocationManager.sharedManager().requestWhenInUseAuthorization()
        LocationManager.sharedManager().startUpdatingLocation()
    }
    
   
 
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
      refresh()
      
    
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
    

    @IBOutlet weak var stackViewHiddenConstraint: NSLayoutConstraint!
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
//      print(locations)
      
        guard let loc = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func userDidTapMapView(sender: UITapGestureRecognizer) {
      toggleView()
    }
   
   func toggleView() {
    
    isRotating = false
     
      if mapToTableRatioConstraint.active {
        
         NSLayoutConstraint.deactivateConstraints([mapToTableRatioConstraint])
         NSLayoutConstraint.activateConstraints([mapToTableRatioExpandedConstraint])
         
      } else if mapToTableRatioExpandedConstraint.active {
         
         NSLayoutConstraint.deactivateConstraints([mapToTableRatioExpandedConstraint])
         NSLayoutConstraint.activateConstraints([mapToTableRatioConstraint])
      }
      
      
      UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations:
         
         { () -> Void in
            
         self.up = !self.up
         
         self.view.layoutIfNeeded()
         
         }) { done in
            
      }
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
      print("CURRENT USER ID: \(User.currentUserID)")
      print(tour.id)
        if let usrID = tour.user_id, let currentUserID = User.currentUserID where usrID == currentUserID {
         print("!!", usrID, currentUserID)
            cell.myTour = true
            
        } else {
         cell.myTour = false
      }
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
    
    var isRotating: Bool = true
    
    override func viewDidLayoutSubviews() {
        
        if isRotating { up = true }
        isRotating = true
        
    }
   
   let defaultPinID = "com.macbellingrath.pin"
   
   
   func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
      
      let pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(defaultPinID)
      
      guard let pv = pinView else {
         
        let pinV =  MKAnnotationView(annotation: annotation, reuseIdentifier: defaultPinID)
         pinV.annotation = annotation
         
         pinV.canShowCallout = true
         
         if let compassImage = UIImage(named: "compass") {
            
            pinV.image = compassImage
         
         }
         pinV.frame.size = CGSize(width: 30, height: 30)
         return pinV
      }
      return pv
   }
}
