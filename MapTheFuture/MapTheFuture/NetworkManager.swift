//
//  NetworkManager.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/30/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import KeychainSwift

private let _sharedInstance = NetworkManager()

class NetworkManager: NSObject {
    
    typealias JSON = [String: AnyObject]
    
    class func sharedManager() -> NetworkManager {
        return _sharedInstance
    }
    
//    static let sharedInstance: NetworkManager = {
//        let nm = NetworkManager()
//        if let token = KeychainSwift().get("token") {
//            print(token)
//        
//        // Create manager
//        let manager = Manager.sharedInstance
//        
//        
//        
//        manager.session.configuration.HTTPAdditionalHeaders = [
//            "token": token,
//            "Content-Type":"application/json",
//        ]
//        }
//        return nm
//
//        
//    }()
    
    /**
     Get All Tours (GET https://fathomless-savannah-6575.herokuapp.com/tours)
     */
    func getAllTours(completion:(success: Bool, tours: [Tour])->()){

        // Fetch Request
        Alamofire.request(.GET, "https://fathomless-savannah-6575.herokuapp.com/tours", parameters: nil).responseArray("tours", completionHandler: { (response: Response<[Tour], NSError>) -> Void in
                
                print("response result \(response.result.value)")
                
                if let tourArray = response.result.value {
                    completion(success: true, tours: tourArray)
                    print(tourArray)
                
                } else {
                    
                    completion(success: false, tours: [])
            }
        }
    )}
    
    
    
    /**
     Create a New tour
     
     - parameter title: Provide a title for the tour
     Creating a New Tour (POST https://fathomless-savannah-6575.herokuapp.com/tours/)
     */
    func createTour(title: String, success:(Bool)->()) {

        let URLParameters = [
            
            "title": title
        ]
        
        // Fetch Request
        Alamofire.request(.POST, "https://fathomless-savannah-6575.herokuapp.com/tours/", parameters: URLParameters)
            .validate(statusCode: 200..<300).responseJSON(completionHandler: { (response) -> Void in
                
                switch response.result {
               
                case .Failure(let error):
                    print(error)
                    success(false)
               
                case .Success(let value):
                     success(true)
                    print(value)
                    
                }
            })
      }
    
    
    /**
     Signs up a new User
     
     - parameter firstName: user's first name
     - parameter lastName:  user's last name
     - parameter email:     user's email
     - parameter password:  a password for the user's account
     
     Signup (POST https://fathomless-savannah-6575.herokuapp.com/signup)
     */
    func signUp(firstName: String, lastName: String, email: String, password: String, completion:(success: Bool, statusCode: Int)->() ) {
        
        let URLParameters: [String : AnyObject] = [
            "first_name": firstName,
            "last_name":lastName,
            "email": email,
            "password": password,
        ]
        
        // Fetch Request
        Alamofire.request(.POST, "https://fathomless-savannah-6575.herokuapp.com/signup", parameters: URLParameters).responseObject("user", completionHandler: { (response: Response<User, NSError>) -> Void in
            
            if let status = response.response?.statusCode {
                
                if  let user = response.result.value {
                    print("going to try to save user \(user.firstName, user.lastName, user.id)")
                    
                    //Save User into keychain
                    //Background
                    
                    user.save()
                    
                    completion(success: true, statusCode: status)
                    
                } else {
                    completion(success: false, statusCode: status)
                }
            }
        })
    }
    
    
    
    
    
   
    
    
    
    func login(email: String, password: String, success:(Bool)->()){
      
            
            // Login (POST https://fathomless-savannah-6575.herokuapp.com/user/show)
            
            
            let URLParameters = [
                "email": email,
                "password": password,
            ]
            
            // Fetch Request
        Alamofire.request(.POST, "https://fathomless-savannah-6575.herokuapp.com/user/show", parameters: URLParameters).responseObject("user", completionHandler: { (response: Response<User, NSError>) -> Void in
            
            print(response.result.value?.accessToken)
            if let user = response.result.value {
                user.save()
                
                print("login: \(response.result.value?.accessToken)")
               success(true)
            } else {
                print(response.result.error)
                success(false)
            }
        })
    }
    
    
    /**
     Gets sites for a particular Tour
     
     - parameter tourID:  The ID of the tour
     
     Display Individual Site (GET https://fathomless-savannah-6575.herokuapp.com/tours/8/sites)
    
     */
    func getSitesforTour(tourID: Int, completion: (success: Bool, sites: [Site]) -> ()) {
        
        guard let token = KeychainSwift().get("token") else { return }
            
            // Create manager
            let manager = Manager.sharedInstance
        
        
        
            manager.session.configuration.HTTPAdditionalHeaders = [
            "token": token,
            "Content-Type":"application/json",
            ]

            
            let encoding = Alamofire.ParameterEncoding.JSON
            // Fetch Request
        Alamofire.request(.GET, "https://fathomless-savannah-6575.herokuapp.com/tours/\(tourID)/sites", parameters: nil, encoding: encoding).responseArray("sites") { (response: Response<[Site], NSError>) -> Void in
            
            switch response.result {
                
            case .Failure(let error):
                print("Error getting sites for tour \(error)")
                completion(success: false, sites: [])
            case .Success(let sites):
                print(sites)
                completion(success: true, sites: sites)
                
                }
            }
        }
    
    
    func uploadPhoto(photo: UIImage, completion:(success: Bool)->()) {
        
        print("about to upload photo")
        
        if let png = UIImagePNGRepresentation(photo) {
            print("obtained png")
            
        let keychain = KeychainSwift()
            
         guard let id = keychain.get("id"), let token = keychain.get("token") else { return print("Couldn't get id or token")}
            
            keychain.set(png, forKey: "profileImage")
   
           let headers = [
            
                "token": token
            ]
    
            Alamofire.upload(.PATCH, "https://fathomless-savannah-6575.herokuapp.com/user/\(id)/update", headers: headers, data: png).responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: { (response) -> Void in
                print("uploading!")
                
                switch response.result {
                
                case .Failure(let error):
                    print(error)
                    completion(success: false)
                case .Success(let value):
                    print(value)
                    completion(success: true)
                }
            })
        }
    }
}


