//
//  RoutingViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/18/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBook
import Contacts

@IBDesignable
class RoutingViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipField: UITextField!
    var coords: CLLocationCoordinate2D?
    var pm: MKPlacemark?
    var route: MKRoute?
    
    @IBOutlet weak var routeMap: MKMapView!
    
    @IBAction func getDirectionsButtonPressed(sender: AnyObject) {
        guard let a = addressTextField.text, let c = cityTextField.text, let s = stateTextField.text, let z = zipField.text where [a,c,s,z]>* else { return }
        
        let geoCoder = CLGeocoder()
        let addressString = "\(a) \(c) \(s) \(z)"
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) -> Void in
            if error != nil { print(error?.localizedDescription) }
            
            guard let pm = placemarks?.first, let loc = pm.location else { return }
            self.coords = loc.coordinate
            self.showMap()

        }
    }

    func showMap(){
        
        guard let a = addressTextField.text, let c = cityTextField.text, let s = stateTextField.text, let z = zipField.text where [a,c,s,z]>* else { return  }
        
      
        
        let addressDictionary = [
            CNPostalAddressStreetKey as String: a,
            CNPostalAddressCityKey as String: c,
            CNPostalAddressStateKey as String: s,
            CNPostalAddressPostalCodeKey as String: z
        ]
        
        guard let coordinates = coords else { return }
        
        let place = MKPlacemark(coordinate: coordinates, addressDictionary: addressDictionary)
        
        self.pm = place
        
        let mapItem = MKMapItem(placemark: place)
        
        getDirections()
        
//        let options = [MKLaunchOptionsDirectionsModeKey:
//            MKLaunchOptionsDirectionsModeDriving]
//        
//        mapItem.openInMapsWithLaunchOptions(options)
        
       
    }
    
    func getDirections() {
        guard let p = pm else { return }
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = MKMapItem(placemark: p)
        request.transportType = .Walking
        
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if error != nil { print(error?.localizedDescription) }
            else {
                guard let dirResp = response else { return }
               
                print(dirResp.routes)
                print("eta: \(dirResp.routes.first?.expectedTravelTime)")
                
        
                self.showRoute(dirResp)
               
            }
        }
    }
    
    func showRoute(response: MKDirectionsResponse  ) {
        
        route = response.routes.first
        performSegueWithIdentifier("ShowSteps", sender: self)

        for route in response.routes {
            routeMap.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            for step in route.steps {
                print(step.instructions)
            }
        }
    }

    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
       
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "ShowSteps" else { return print("incorrecct segue") }
        
        guard let stepsTVC = segue.destinationViewController as? StepsTableViewController else { return print("destination is not StepsTableViewController")}
        
        stepsTVC.route = route
        print("route set on destinationvc")
    }
        
}


    




