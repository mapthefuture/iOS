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

class Tour: Mappable {
    
    var id: Int?
    var length: String?
    var title: String?
    var user_id: Int?
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        length <- map["length"]
        title <- map["title"]
        user_id <- map["user_id"]
    }
    
}