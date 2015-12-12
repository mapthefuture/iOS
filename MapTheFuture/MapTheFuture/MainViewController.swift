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


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,  MKMapViewDelegate, UISearchBarDelegate {
   
   
   lazy var locationMgr: CLLocationManager = {
     
      let locmgr = CLLocationManager()
      locmgr.delegate = self
      locmgr.requestWhenInUseAuthorization()
      return locmgr
      
   }()
   
   var tours: [Tour] = [] {
      
      didSet {
         
         print(tours.flatMap{$0.id})
         
        _ = tours.map({ t in
         
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
       
        
         
         imageViewtoTopConstraint.constant = mapToTableRatioConstraint.active ? 20 : -100
            
         upArrow.transform = CGAffineTransformMakeRotation(CGFloat(((up ? 0 : -180) * (M_PI / 180))))

         upArrow.setNeedsDisplay()
         
         upArrow.updateConstraintsIfNeeded()
        
        
      }
   }
   
   var tapGR: UISwipeGestureRecognizer?
   
   @IBOutlet weak var mapView: MKMapView! {
      didSet {
         mapView.showsCompass = true
         mapView.showsScale = true
      }
   }
   
    var searchController:UISearchController!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func arrowButtonPressed(sender: AnyObject) {
      toggleView()
    }
   
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
       locationMgr.requestLocation()
   }
   

   
   
 //MARK: - View Controller Lifecycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
      if CLLocationManager.locationServicesEnabled() {
         switch CLLocationManager.authorizationStatus() {
            
         case .Denied, .NotDetermined, .Restricted:
            locationMgr.requestWhenInUseAuthorization()
         case .AuthorizedAlways, .AuthorizedWhenInUse: break
         }
       
      }
      locationMgr.requestLocation()
      
      let keychain = KeychainSwift()
      if let name = keychain.get("name") {
         greetingLabel.text = "Hello, \(name)"
         
      }
      
      
      if let data = keychain.getData("profileImage"), let image = UIImage(data: data) {

            imageView.image = image
     
      } else {
      
         NetworkManager.sharedManager().downloadProfileImage { [weak self] (success, profileImage) -> () in
         if let prof = profileImage {
            self?.imageView.image = prof
            self?.imageView.contentMode = .ScaleAspectFill
            if let imgD = UIImagePNGRepresentation(prof) {
            keychain.set(imgD, forKey: "profileImage")
               }
            }
         }
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
   override func viewDidLayoutSubviews() {
      
//      if isRotating { up = true }
//      isRotating = true
      
   }
   func showNearby() {

//      TODO
   }
   
   
   override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)

   }
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
      guard segue.identifier == "ShowTourDetail", let siteTVC = segue.destinationViewController as? SiteTableViewController else { return }
      
      guard let selected = tableView.indexPathForSelectedRow?.row else { return }
      let tour = tours[selected]
      siteTVC.tour = tour
   }

   
    deinit {
      //
   }
    
    
    //MARK: - Constraints
    @IBOutlet weak var mapToTableRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapToTableRatioExpandedConstraint: NSLayoutConstraint! 
    
    @IBOutlet weak var imageViewtoTopConstraint: NSLayoutConstraint!
   
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
      
        guard let loc = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        self.mapView.setRegion(region, animated: true)
    }
    
   var effectView: UIVisualEffectView?
   
   func toggleView() {
      
      
         if self.up {
            let effect = UIBlurEffect(style: .ExtraLight )
            
            effectView = UIVisualEffectView(effect: effect)
            effectView?.frame = self.mapView.frame
            
            if let _efv = self.effectView {
               mapView.addSubview(_efv)

            }
            
         } else if !(up) {
            effectView?.removeFromSuperview()
         }
      

     
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
    
    
   
//    var isRotating: Bool = true
   
 
   
   let defaultPinID = "com.macbellingrath.pin"
   
   
   func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
      
      if annotation.coordinate ^= mapView.userLocation.coordinate {
         return nil
      }
      
      let pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(defaultPinID) as? WanderfulAnnotationView
      
      guard let pv = pinView  else {
         
         
        let pinV =  WanderfulAnnotationView(annotation: annotation, reuseIdentifier: defaultPinID)


         return pinV
      }
      return pv
   }
   
   //MARK: - Location Manager
   
   func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
      print(error)
   }
}

