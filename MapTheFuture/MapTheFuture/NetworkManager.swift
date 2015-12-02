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
    
        let URLParameters = [
            "first_name": firstName,
            "last_name":lastName,
            "email": email,
            "password": password,
        ]
        
        // Fetch Request
        Alamofire.request(.POST, "https://fathomless-savannah-6575.herokuapp.com/signup", parameters: URLParameters).responseObject { (response: Response<User, NSError>)  in
            
            print("User Created: \(response.result.value)")
            
            if let status = response.response?.statusCode {
            
            if  response.result.value != nil {
                completion(success: true, statusCode: status)
                
            } else {
                completion(success: false, statusCode: status)
                }
            }
        }
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
            if let user = response.result.value, let token = user.accessToken, let name = user.firstName {
                let keychain = KeychainSwift()
                keychain.set(token, forKey: "token")
                keychain.set(name, forKey: "name")
                print("login: \(response.result.value)")
               success(true)
            } else {
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
        
        
            
            // Create manager
            var manager = Manager.sharedInstance
            
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
}


