//
//  CreateViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/25/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import STPopup

class AddSitesViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    private let cellID = "SiteCell"
    
    var tour: Tour? {
        didSet {
            if let _t = tour?.category {
                self.navigationController?.title = tour?.title
                search(_t)
            }
            print("AddSitesVC Tour Set: \(tour?.title)")
        }
    }
    var sites: [Site?] = []
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var searchRegion: MKCoordinateRegion? {
        didSet {
            mapView.setRegion(searchRegion!, animated: true)
        }
    }
    
    @IBOutlet weak var tv: UITableView!
    
    
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {

        //todo
        //Save tour with sites
        guard let _tour = self.tour else { return }
        Loading.start()
        for site in sites.flatMap({$0}) {
            NetworkManager.sharedManager().createSiteforTour(site, tour: _tour, completion: { (success) -> () in
                Loading.stop()
               
                if success {
                    
                    if let _id = _tour.id, let first = self.sites.first, let coord = first?.coordinate {
                        
                        let coordParams = [
                            "start_lat" : coord.latitude,
                            "start_lon": coord.longitude
                        ]
                        print(coordParams)
                    //Update Tour
                    NetworkManager.sharedManager().updateTour(_id, params:
                        coordParams,
                        
                        success: { (success) -> () in
                        
                        if success {
                            print(success)
                        } else if !success {
                            print("failure")
                            
                            }
                        })
                    }
                
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else if !success {
                    
                    print("failed")
                    self.alertUser("Uploading these sites failed.", message: "Please check your network connection and try agian.")
                }
            })
            
        }

    }
   @objc var mapresponseObjects: [MKMapItem] = [] {
        
        didSet {
            
            _ = mapView.annotations.map { mapView.removeAnnotation($0)}
            
            for i in mapresponseObjects {
                let mapPin = MKPointAnnotation()
                
                //todo - replace name
                mapPin.title = i.name ?? "Default Item Name"
                mapPin.coordinate = i.placemark.coordinate
                mapView.addAnnotation(mapPin)
                
            }
            tv.reloadData()
            if let region = searchRegion { mapView.setRegion(region, animated: true) }
        }
    }
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
  
    @IBOutlet weak var mapView: MKMapView!     

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.sharedManager().delegate = self
        LocationManager.sharedManager().requestWhenInUseAuthorization()
        LocationManager.sharedManager().requestLocation()
        
    }
    

    func showSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        
        presentViewController(searchController, animated: true, completion: nil)
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchtext = searchBar.text {
            search(searchtext)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    func search(searchText: String) {
        
        //
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchText
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            else if let searchResponse = localSearchResponse  {
                
                self.mapresponseObjects = searchResponse.mapItems
                self.searchRegion = searchResponse.boundingRegion
                
                
                }
            }
    }
    
    
    //TableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! AddSiteTableViewCell
        
        let item = mapresponseObjects[indexPath.row]
        cell.mapItem = item
        
        cell.textLabel?.text = item.name
        
           
        
        return cell
    }
    
    
 

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapresponseObjects.count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell =  tableView.cellForRowAtIndexPath(indexPath) as?
            
            AddSiteTableViewCell {
                if cell.added == false {
                cell.added = true
                let item = mapresponseObjects[indexPath.row]
                guard let tour = self.tour, let id = tour.id, let name = item.name else { return print("Tour missing info") }
                let site = Site(tourID: id, title: name, coordinate: item.placemark.coordinate)
                sites.append(site)
                print(sites)
                    
                } else if cell.added == true {
                    
                    cell.added = false
                   
                    if let arrayindex = sites.indexOf({ (site) -> Bool in
                        
                        site?.title == cell.mapItem?.name
              
                         }) {
                    sites.removeAtIndex(arrayindex)
                    
                            print(sites)
                    }

                }
        }
    }

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print(indexPath)
      
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let dark = UIImage(named:"addBlue") {
                let imageView = UIImageView(image: dark)
                imageView.frame.size = CGSize(width: 50, height: 50)
                imageView.contentMode = .ScaleAspectFit
                cell.accessoryView = imageView
            }
        }
        
        let item = mapresponseObjects[indexPath.row]

        guard let tour = self.tour, let id = tour.id, let name = item.name else { return print("Tour missing info") }
        let site = Site(tourID: id, title: name, coordinate: item.placemark.coordinate)
        sites.append(site)
        print(sites)
        
        
    }


    

    //MapView

    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        
    }
    
    //Mark: - Location Manger
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 
    }
 
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Pass the selected object to the new view controller.
    }
    

}
