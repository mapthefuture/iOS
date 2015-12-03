//
//  Site.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/2/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import ObjectMapper
import CoreLocation

class Site: Mappable {
    
    var id: Int?
    var tourID: Int?
    var title: String?
    var description: String?
    var lat: String?
    var lon: String?
    var coordinate: CLLocationCoordinate2D? {
        print(lat, lon)
        guard let lat = self.lat, let long = self.lon, let dlat = Double(lat),  let dlong = Double(long)  else { return nil }

       
        
        return CLLocationCoordinate2D(latitude: dlat, longitude: dlong)
      
    }
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        tourID <- map["length"]
        title <- map["title"]
        description <- map["description"]
        lat <- map["lat"]
        lon <- map["lon"]
    }
}