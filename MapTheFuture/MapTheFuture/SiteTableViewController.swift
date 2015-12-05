//
//  SiteTableViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/2/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}


class SiteTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var tour: Tour?
    var sites: [Site] = []
    var coords:[CLLocationCoordinate2D] = []
    var routes: [MKRoute] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var currentLocCoord: CLLocationCoordinate2D? = {
        let lazymanager = CLLocationManager()
        lazymanager.delegate = self
        lazymanager.requestLocation()
        return lazymanager.location?.coordinate
    }()


    @IBOutlet weak var tourTitleLabel: UILabel!
    
    @IBAction func goButtonPressed(sender: AnyObject) {
        
    }
    
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
            
            if error != nil { completion(nil); print(error) }
            
            if let r = response {
                
                completion(r.routes.first)
            }
            
        }

    }
    
    func getSitesAndSteps() {

        routes = []
        
        //Get sites
        if let t = tour, let id = t.id { NetworkManager.sharedManager().getSitesforTour(id, completion: { [unowned self] (success, sites)
            
            in if success == true {
               
                print("sites: \(sites)")
            
                //succesfully got sites
                self.sites = sites
                
                
                //put coordinates into array
                self.coords = sites.flatMap{$0.coordinate}
//                let a = CLLocationCoordinate2D(latitude: 33.7587, longitude: -84.3645782)
//                let b = CLLocationCoordinate2D(latitude: 33.7987, longitude: -84.55)
//                let c = CLLocationCoordinate2D(latitude: 33.7387, longitude: -84.3745782)
//                
//                self.coords = [a,b,c]
                
                
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
                        }
                    })
                }
                
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        getSitesAndSteps()
    }
    
    
                    
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSitesAndSteps()
        tourTitleLabel.text = tour?.title ?? ""
        title = tour?.title ?? "Tour"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            if let coord = site.coordinate, let currentcoord = self.currentLocCoord {
               
                let map = MKMapView(frame: sectionView.frame)
                
                    map.delegate = self
                    sectionView.addSubview(map)
                    
                    map.center = sectionView.center
                
                if let route = routes[safe: section] {
                    print("polyline : \(route.polyline)")
                    map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
                }
                
                if section == 0 {
                    map.showsUserLocation = true
                    
                    map.setRegion(MKCoordinateRegion(center: currentcoord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
                    
                } else if section > 0 {
                    map.setRegion(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
                }
                
                }
                
                //Title Label
                let sectionTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: sectionView.frame.width / 2, height: sectionView.frame.height / 2))
                sectionTitleLabel.text = site.title ?? "Default Title"
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
        // #warning Incomplete implementation, return the number of rows
        return routes[safe: section]?.steps.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        if let stepString = routes[safe: indexPath.section]?.steps[safe: indexPath.row]?.instructions, let step = routes[safe: indexPath.section]?.steps[indexPath.row]  {
            cell.textLabel?.text = stepString
            cell.detailTextLabel?.text = "\(step.distance.metersToMiles()) miles"
        }
        

        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    //MARK: - MAP VIEW
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.cyanColor()
        renderer.lineWidth = 10.0
        return renderer
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


