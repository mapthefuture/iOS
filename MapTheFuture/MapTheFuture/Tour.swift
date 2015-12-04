//
//  Tour.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 12/1/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import ObjectMapper
import CoreLocation

class Tour: Mappable {
    
    var id: Int?
    var user_id: Int?
    var title: String?
    var length: String?
    var distance: Double?
    var duration: Double?
    var startLat: String?
    var startLong: String?
    var category: String?
    var description: String?
    var coordinate: CLLocationCoordinate2D? {
        print(startLat, startLong)
        guard let lat = self.startLat, let long = self.startLong, let dlat = Double(lat),  let dlong = Double(long)  else { return nil }
        return CLLocationCoordinate2D(latitude: dlat, longitude: dlong)
        
    }

    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        user_id <- map["user_id"]
        title <- map["title"]
        length <- map["length"]
        distance <- map["distance"]
        duration <- map["duration"]
        startLat <- map["start_lat"]
        startLong <- map["start_lon"]
        category <- map["category"]
        description <- map["description"]
    }
    
}

//"id": 8,
//"user_id": 5,
//"title": "The East Side",
//"distance": 3.0,
//"duration": 2,
//"start_lat": "33.8428",
//"start_lon": "84.3857",
//"category": "Food",
//"description": "Lots of corn mazes"




