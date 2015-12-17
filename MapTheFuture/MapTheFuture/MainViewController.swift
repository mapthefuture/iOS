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
import AlamofireImage
import STPopup


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,  MKMapViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
   

   lazy var locationMgr: CLLocationManager = {
     
      let locmgr = CLLocationManager()
      locmgr.delegate = self
      locmgr.requestWhenInUseAuthorization()
      return locmgr
      
   }()
   
  
   
   var tours: [Tour] = [] {
      
      didSet {
         
         print(tours.flatMap{$0.id})
         
         let loc = mapView.userLocation.coordinate
         
         tours = tours.filter{$0.distance(from: loc) > 0}.sort{ $0.distance(from: loc) < $1.distance(from: loc) }
         
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
   
   
   
   func calcDistances() -> [CLLocationDistance]? {
  
      var distArray: [CLLocationDistance] = []
      _ = mapView.annotations.flatMap{$0}.map{
         let lat = $0.coordinate.latitude
         let lon = $0.coordinate.longitude
         let loc = CLLocation(latitude: lat, longitude: lon)
         if let currentLoc = mapView.userLocation.location {
         
            distArray.append(loc.distanceFromLocation(currentLoc))
         }
      }
//      print(distArray)
      return distArray.isEmpty ? nil : distArray
   }
   

   var up = false {
     
      didSet {
       
         
         imageViewtoTopConstraint.constant = mapToTableRatioConstraint.active ? 20 : -100
            
         upArrow.transform = CGAffineTransformMakeRotation(CGFloat(((up ? 180 : 0) * (M_PI / 180))))

         upArrow.setNeedsDisplay()
         
         let span = up ? MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10) : MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
         let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
         
         mapView.setRegion(region, animated: true)
      
         
         upArrow.updateConstraintsIfNeeded()
        
        
      }
   }
   

   
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
   @IBOutlet weak var imageView: UIImageView! {
      didSet {
         
         let tapGR = UITapGestureRecognizer(target: self, action: "viewProfile:")
         tapGR.numberOfTapsRequired = 1
         tapGR.delegate  = self
         imageView.addGestureRecognizer(tapGR)
      }
   }
   
   func viewProfile(sender: UITapGestureRecognizer) {
      print("tapped")
      
      navigationController?.performSegueWithIdentifier("showProfile", sender: self)
      
   }

    @IBAction func arrowButtonPressed(sender: AnyObject) {
      toggleView()
    }
   
    func refresh(completion:()->()) {

      
//      Loading.start()
      if tours.isEmpty { print(1); toggleView() }
      
      NetworkManager.sharedManager().getAllTours { [weak self] (success, tours) -> () in
         
         if success == false {
            completion()
            self?.alertUser("Failed to get tours", message: "We're having trouble connecting to the network. Try again")
            
         } else {
           
               
               self?.tours = tours
            
            
            
//            Loading.stop()
            completion()
            print(2)
            self?.toggleView()
            
         }
      }
   }
   


    @IBAction func findMeButtonPressed(sender: AnyObject) {
       locationMgr.requestLocation()
      refresh { () -> () in
         
      }
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
      
      if let avURL = KeychainSwift().get("avatarURL"), let _url = NSURL(string: avURL) {
         let filter = AspectScaledToFillSizeCircleFilter(size: imageView.frame.size)
         imageView.af_setImageWithURL(_url, placeholderImage: UIImage(named: "placeholder"), filter: filter , imageTransition: .CrossDissolve(0.1))
      }
      
//      imageView.getProfilePicture()
      
      refresh { () -> () in
         print("Refreshed")
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
      

      
   


    }
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

//      tableView.addPullToRefresh(refresher) { () -> () in
//         self.refresh({ () -> () in
//            self.tableView.endRefreshing()
//         })
//      }
   }

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
      guard segue.identifier == "ShowTourDetail", let siteTVC = segue.destinationViewController as? SiteTableViewController else { return }
      
      guard let selected = tableView.indexPathForSelectedRow?.row else { return }
      let tour = tours[selected]
      siteTVC.tour = tour
   }


    
    //MARK: - Constraints
    @IBOutlet weak var mapToTableRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapToTableRatioExpandedConstraint: NSLayoutConstraint! 
    
    @IBOutlet weak var imageViewtoTopConstraint: NSLayoutConstraint!
   
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
      
      guard let loc = locations.last else { return }
        calcDistances()
      
      let center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
      
      let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        
        self.mapView.setRegion(region, animated: true)
    }
    
   var effectView: UIVisualEffectView?
   
   func toggleView() {
      
   

     
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
            self.mapView.alpha = self.up ? 1.0 : 0.5
            
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
      

     cell.distanceLabel.text = tour.distance(from: mapView.userLocation.coordinate).titleFromDouble()

      
   

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
      return 90
   }
   
//   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//    
//      
//      return distanceCategories.count
//   
//   }
   
   
   
//   var distanceCategories: [String: [CLLocationDistance]] {
//      return calcDistances()?.categorize{$0.titleFromDouble()} ?? [:]
//   }
//
//
//   var distanceLabels: [String] {
//      var array: [String] = []
//     _ =  distanceCategories.keys.map{array.append($0)}
//      return array
//   }
//   let distanceLabels = ["Less than one mile", "One to five miles", "Five to ten miles", "Ten to twenty miles","Twenty to fifty miles", "Far Away", "Unknown"]


   
//   func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//      
//      return distanceLabels[section]
//   }
//   
//   
   
   

    //MARK: - MapView
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
       tours = tours.filter{$0.distance(from: userLocation.coordinate) > 0}.sort{ $0.distance(from: userLocation.coordinate) < $1.distance(from: userLocation.coordinate) }
      
      tableView.reloadData()

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
         if let tour = tours.indexOf({ $0.title == annotation.title ?? ""}){
            let t = tours[tour]
            pinV.tour = t
            
         }


         return pinV
      }
      return pv
   }
   
   func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
         }
   
   //MARK: - Location Manager
   
   func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
      print(error)
   }
}

