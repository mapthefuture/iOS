//
//  FirstViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/18/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit



class FirstViewController: UIViewController, CLLocationManagerDelegate,  MKMapViewDelegate{
    
    
    @IBOutlet weak var mapView: MKMapView!
    

    @IBAction func findMeButtonPressed(sender: AnyObject) {
        LocationManager.sharedManager().requestWhenInUseAuthorization()
        LocationManager.sharedManager().startUpdatingLocation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
  
    
    //MARK: - MapView
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
    }
}

