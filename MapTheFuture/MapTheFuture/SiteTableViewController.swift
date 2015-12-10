//
//  SiteTableViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/2/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit


class SiteTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var tour: Tour?
    var sites: [Site] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var coords:[CLLocationCoordinate2D] = []
    var routes: [MKRoute] = [] {
        didSet {
        
            tableView.reloadData()
            distanceLabel.text = calculateTotalDistanceFrom(routes).metersToMilesString()
            timeEstimateTextLabel.text = calculateTimeEstimateStringFrom(routes)
        }
    }
    
    
    
    @IBOutlet weak var timeEstimateTextLabel: UILabel!
    
    lazy var currentLocCoord: CLLocationCoordinate2D? = {
        let lazymanager = CLLocationManager()
        lazymanager.delegate = self
        lazymanager.requestLocation()
        return lazymanager.location?.coordinate
    }()

  
    @IBOutlet weak var tourTitleLabel: UILabel!
    

    @IBOutlet weak var distanceLabel: UILabel!
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion:(MKRoute?) -> ()) {
        
        Loading.start()
       let fromPM = MKPlacemark(coordinate: from, addressDictionary: nil)
       let toPM = MKPlacemark(coordinate: to, addressDictionary: nil)
        
        let fromMapItem = MKMapItem(placemark: fromPM)
        let toMapItem = MKMapItem(placemark: toPM)
        
        let request = MKDirectionsRequest()
        
        request.source = fromMapItem
        request.destination = toMapItem
        
        request.transportType = .Walking
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            
            if error != nil { Loading.stop(); completion(nil); print(error) }
            
            if let r = response {
                Loading.stop()
                completion(r.routes.first)
            }
            
        }

    }
    
    func getSitesAndSteps(completion completion:(()->())?) {
        
        
        defer { if let _c = completion { _c() } }
        

        
        //Get sites
        if let t = tour, let id = t.id {
            
            NetworkManager.sharedManager().getSitesforTour(id, completion: {  (success, sites)
            
            in if success == true {
               
                print("sites: \(sites)")
            
                //succesfully got sites
                self.sites = sites
                
                
                //put coordinates into array
                self.coords = sites.flatMap{$0.coordinate}

                
                
                if let currloccord = self.currentLocCoord {
                    self.coords.insert(currloccord, atIndex: 0)
                }
                
                print("Coordinates: \(self.coords)")
                
                //loop through coords and create routes
        
                for (index, _coordinate) in self.coords.enumerate() {
                    
                    print("current index: \(index). Coord: \(_coordinate)")
                  
//                    guard let i = index where i < self.coords.count  else { return }
                  
                
                    guard let to = self.coords[safe: index + 1] else { return }
                    
                    self.getRoute(_coordinate, to: to, completion: { (route) -> () in
                        
                        if let _route = route {
                            
                            print(_route)
                            self.routes.append(_route)
                            self.tableView.reloadData()
                            if let c = completion {
                                c()
                            }
                        }
                    })
                }
                
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        distanceLabel.text = calculateTotalDistanceFrom(routes).metersToMilesString()
        timeEstimateTextLabel.text = calculateTimeEstimateStringFrom(routes)
        
        print("Calculation : \(calculateTimeEstimateStringFrom(routes))")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
         routes = []
        
        self.tourTitleLabel.text = tour?.title ?? "Wander"
       self.automaticallyAdjustsScrollViewInsets = false
        

        getSitesAndSteps(completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Table view data source
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
    
    print("number of sections: \(tableView.numberOfSections)")
    return sites.count
        
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        
        let site = sites[section]
        
        
        let map = MKMapView(frame: sectionView.frame)
        
        map.delegate = self
        sectionView.addSubview(map)
        
        map.center = sectionView.center

        
        
            if let coord = site.coordinate {
               
                
                map.setRegion(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: true)
                
                if let route = routes[safe: section] {
                    print("polyline : \(route.polyline)")
                    map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
                }
                
                print(site.title, site.coordinate, map)
                
                } else if site.coordinate == nil {
            if let currentcoord = self.currentLocCoord {
                map.setRegion(MKCoordinateRegion(center: currentcoord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
            }

    
            
                }
                
                //Title Label
                let sectionTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: sectionView.frame.width / 2, height: sectionView.frame.height / 2))
                sectionTitleLabel.text = site.title ?? "Site"
                sectionTitleLabel.textAlignment = .Center
                sectionTitleLabel.textColor = UIColor.darkGrayColor()
                sectionView.addSubview(sectionTitleLabel)
                sectionTitleLabel.center = sectionView.center
        
                //Detail Label
                let sectionDetailLabel = UILabel(frame: CGRect(x: 0, y: 0, width: sectionView.frame.width / 2, height: sectionView.frame.height / 2))
                sectionDetailLabel.text = site.description ?? "Default Description"
                sectionDetailLabel.textAlignment = .Center
                sectionDetailLabel.textColor = UIColor.darkGrayColor()
                sectionView.addSubview(sectionDetailLabel)
                sectionDetailLabel.center = CGPoint(x: sectionView.center.x, y: sectionTitleLabel.center.y + 25)
                
        
        
                return sectionView
                

        
        }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return routes[safe: section]?.steps.count ?? 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if routes.isEmpty {
            cell.textLabel?.text = "Walking directions unavailable for this site."
            
            
        } else if !(routes.isEmpty) {
            if let stepString = routes[safe: indexPath.section]?.steps[safe: indexPath.row]?.instructions, let step = routes[safe: indexPath.section]?.steps[indexPath.row]  {
                cell.textLabel?.text = stepString
                cell.detailTextLabel?.text = "\(step.distance.metersToMiles()) miles"
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getSitesAndSteps(completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    //MARK: - MAP VIEW
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.unitedNationsBlue()
        renderer.lineWidth = 10.0
        return renderer
    }
    


}


