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
import AlamofireImage

class User: Mappable {
    
    var id: Int?
    var email: String?
    var accessToken: String?
    var firstName: String?
    var lastName: String?
    var avatarURL: String?

    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        accessToken <- map["access_token"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        avatarURL <- map["avatar_url"]
    }
    
    class func logOut() {
        let keychain = KeychainSwift()
        keychain.clear()

    }

    
    static let currentUserID: Int? = {

//        guard let firstname = self.firstName, let email = self.email, let id = self.id, let token = self.accessToken else { return nil }
        
        
        let keychain =  KeychainSwift()
        guard let idString = keychain.get("id"), let id = Int(idString)  else { return nil }
        
        return id
    }()
    
    static let accessToken: String? = {

        let keychain =  KeychainSwift()
        return keychain.get("token")

    }()

    
    
    
    func save() {
        print(self.accessToken, self.id, self.firstName, self.lastName)
        guard let firstname = self.firstName,  let email = self.email, let id = self.id,let token = self.accessToken else { return }
        
        let keychain =  KeychainSwift()
        keychain.set(token, forKey: "token")
        keychain.set(firstname, forKey: "name")
        keychain.set(email, forKey: "email")
        keychain.set(String(id), forKey: "id")
        if let avurl = avatarURL {
            keychain.set(avurl, forKey: "avatarURL")
        }
        print("saved User")
        
    }
   }