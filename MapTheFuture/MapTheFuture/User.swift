//
//  User.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 12/1/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//


import UIKit
import AlamofireObjectMapper
import ObjectMapper


class User: Mappable {
    
 
    
    var name: String?
    var user_id: Int?
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        user_id <- map["user_id"]
    }
    
}