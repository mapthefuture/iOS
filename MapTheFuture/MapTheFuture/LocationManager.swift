//
//  LocationManager.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/19/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

private let _sharedManager = LocationManager()

class LocationManager: CLLocationManager {
    
    class func sharedManager() -> LocationManager {
        return _sharedManager
    }
    
    
}
