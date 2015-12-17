//
//  SiteTableViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/2/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit
import STPopup
import PullToMakeFlight

class SiteTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
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
    @IBOutlet weak var mapHeaderView: MKMapView!
    
    
    
    var currentLocCoord: CLLocationCoordinate2D?
    
    let locManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var tourTitleLabel: UILabel!
    

    @IBOutlet weak var distanceLabel: UILabel!
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion:(MKRoute?) -> ()) {
        
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

                completion(r.routes.first)
            }
            
        }

    }
    
    func getSitesAndSteps(completion completion:(()->())?) {
        
        routes = []
        
//        defer { if let _c = completion { _c() } }
        

        locManager.requestLocation()
        //Get sites
        if let t = tour, let id = t.id {
            
            NetworkManager.sharedManager().getSitesforTour(id, completion: {  (success, sites)
            
            in if success == true {
               
                print("sites: \(sites)")
            
                //succesfully got sites
                self.sites = sites
                
                
                //put coordinates into array
                self.coords = sites.map{$0.coordinate ?? CLLocationCoordinate2D()}
                
                if sites.count == 1 {
                    if let c = self.locManager.location?.coordinate {
                        self.coords.insert(c, atIndex: 0)
                    }
                }

                
                print("Coordinates: \(self.coords)")
                
                //loop through coords and create routes
            
                if self.routes.count > 0 { self.routes = [] }
        
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
    
   
    let refresh = PullToMakeFlight()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        routes = []
        
       self.tourTitleLabel.text = tour?.title ?? "Wander"
       self.automaticallyAdjustsScrollViewInsets = false
        
        locManager.delegate = self
        locManager.requestLocation()
       
        self.currentLocCoord = locManager.location?.coordinate

        refresh.hideDelay = 1.5
        tableView.addPullToRefresh(refresh) {
            
            self.getSitesAndSteps { self.tableView.endRefreshing() }
            
        }
        self.getSitesAndSteps { () -> () in
            self.tableView.reloadData()
        }
        

    }
    
    @IBAction func moreButtonPressed(sender: AnyObject) {
        print("MORE PRESSED")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     let reuseID = "headerView"


    // MARK: - Table view data source
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
    
    print("number of sections: \(tableView.numberOfSections)")
    return sites.count >= 1 ? sites.count : 1
        
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    

    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        guard !(sites.isEmpty) else {
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
            //Title Label
            let sectionTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: emptyView.frame.width / 2, height: emptyView.frame.height / 2))
            sectionTitleLabel.text = "No Sites have been added to this tour."
            sectionTitleLabel.numberOfLines = 0
            sectionTitleLabel.sizeToFit()
            sectionTitleLabel.textAlignment = .Center
            sectionTitleLabel.textColor = UIColor.darkGrayColor()
            emptyView.addSubview(sectionTitleLabel)
            sectionTitleLabel.center = emptyView.center
            return emptyView

        }

        //Get Site
        let _site = sites[section]

        //Check for the site's coordinate
        if let coord = _site.coordinate {
            
                
                let polyLines =   routes.flatMap{ $0.polyline }
                mapHeaderView.addOverlays(polyLines, level: .AboveRoads)
                
                if let first = mapHeaderView.overlays.first {
            
                let rect =  mapHeaderView.overlays.reduce(first.boundingMapRect, combine: { MKMapRectUnion($0, $1.boundingMapRect)})
                    
                     mapHeaderView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
                }
        }
        
    
        if let headerV = tableView.dequeueReusableCellWithIdentifier(reuseID) as? SiteSectionHeaderTableViewCell {
            
        
              headerV.contentView.backgroundColor = UIColor.unitedNationsBlue()
          
            
           
            if !(_site.hasImage()){
                headerV.cameraIcon.hidden = true
            }
            if let audiourl = _site.audioURL  {
                if audiourl.containsString("missing") {
                    headerV.audioIcon.hidden = true
                }
            }
            if let descrip = _site.description {
                if descrip.characters.count == 0 {
                    headerV.noteIcon.hidden = true
                }
            }
            
                headerV.site = _site
            
            let tapGR = UITapGestureRecognizer(target: self, action: "headerTapped:")
            tapGR.numberOfTapsRequired = 1
            tapGR.delegate = self
            
            headerV.addGestureRecognizer(tapGR)

            print(headerV.site)
                return headerV
            
        }
        
        return nil

    }
    
    func headerTapped(sender: UITapGestureRecognizer) {
        print("header tapped \(sender.view)")
        guard let hv = sender.view as? SiteSectionHeaderTableViewCell, let selectedSite = hv.site else { return }
        if let v = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PopUpController") as?
            
            SiteDetailPopupViewController {
                
                
                
                let popup = STPopupController(rootViewController: v)
                v.site = selectedSite
                
                popup.cornerRadius = 4
                
                popup.navigationBar.barTintColor = UIColor.unitedNationsBlue()
                popup.navigationBar.tintColor = UIColor.whiteColor()
                popup.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15, weight: UIFontWeightMedium), NSForegroundColorAttributeName: UIColor.whiteColor()]
                
                popup.presentInViewController(self)
                
//                v.site = selectedSite
                
                
        }

        
        
        
    }
    

    var site: Site?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
//        guard let selectedSite = sites[safe: indexPath.section] else { return print("NO: \(indexPath.row, indexPath.section)") }
        
       
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return routes[safe: section]?.steps.count ?? 1
    }

    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if routes[safe: indexPath.section] == nil {
            
            cell.textLabel?.text = "Walking directions unavailable for this site."
            
        } else if !(routes.isEmpty) {
            
            if let stepString = routes[safe: indexPath.section]?.steps[safe: indexPath.row]?.instructions, let step = routes[safe: indexPath.section]?.steps[indexPath.row] {
                
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
        if let loc = locations.last {
            currentLocCoord = loc.coordinate
        }
//        getSitesAndSteps (completion: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "showSiteDetail" else { return }
        guard let siteDetailVC = segue.destinationViewController as? SiteDetailViewController else { return }
//            siteDetailVC.site = site
        
        
    }
    


}




