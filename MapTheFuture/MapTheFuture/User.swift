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
import KeychainSwift


class User: Mappable {
    
 
    var id: Int?
    var email: String?
    var accessToken: String?
    var firstName: String?
    var lastName: String?

    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        accessToken <- map["access_token"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
    }
    
    class func logOut() {
        let keychain = KeychainSwift()
        keychain.clear()
        
        let userSB = UIStoryboard(name: "User", bundle: nil)
        if let nav = userSB.instantiateInitialViewController() as? UINavigationController {
            UIApplication.sharedApplication().windows.first?.rootViewController = nav
        }
        
    }
   }