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
    var imageURL: String?
    var audioURL: String?
    var averageRating: Int?
    var image: UIImage?
    var coordinate: CLLocationCoordinate2D? {
        print(lat, lon)
        guard let lat = self.lat, let long = self.lon, let dlat = Double(lat), let dlong = Double(long) else { return nil }

        return CLLocationCoordinate2D(latitude: dlat, longitude: dlong)
      
    }
    
    required init?(_ map: Map){
        
    }
    
    func distance(fromCoordinate: CLLocationCoordinate2D) -> Double? {
        
        if let x = self.coordinate {
            let lat = x.latitude
            let lon = x.longitude
            let loc = CLLocation(latitude: lat, longitude: lon)
            let currentLoc = CLLocation(latitude: fromCoordinate.latitude, longitude: fromCoordinate.longitude)
                
               return loc.distanceFromLocation(currentLoc)
        }
        return nil
    }
    
    init(tourID: Int, title: String, coordinate: CLLocationCoordinate2D, description: String, image: UIImage?) {
        self.tourID = tourID
        self.title = title
        self.lat = String(coordinate.latitude)
        self.lon = String(coordinate.longitude)
        self.description = description
        self.image = image
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        tourID <- map["tour_id"]
        title <- map["title"]
        description <- map["description"]
        lat <- map["latitude"]
        lon <- map["longitude"]
        imageURL <- map["image_url"]
        audioURL <- map["audio_url"]
        averageRating <- map["average_rating"]
    }
    func hasImage() -> Bool {
        guard let url = self.imageURL else { return false }
        if url.containsString("missing") {
            return false
        } 
        return true
    }
    func uploadImage(completion:(success: Bool)->()) {
        
        if let image = self.image {
            print("obtained photo")
            NetworkManager.sharedManager().uploadPhotoForSite(self, photo: image, completion: { (success) -> () in
                completion(success: success)
            })
            
            }
        else { completion(success: false) }
        }
}