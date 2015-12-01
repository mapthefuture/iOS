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
    
    
    func createTour(title: String) {
        
        // Creating a New Tour (POST https://fathomless-savannah-6575.herokuapp.com/tours/)
        
        
        let URLParameters = [
            "title":"Donuts in Brooklyn",
            "length":"1 hour",
        ]
        
        // Fetch Request
        Alamofire.request(.POST, "https://fathomless-savannah-6575.herokuapp.com/tours/", parameters: URLParameters)
            .validate(statusCode: 200..<300)
            .responseJSON{(request, response, JSON, error) in
                if (error == nil)
                {
                    println("HTTP Response Body: \(JSON)")
                }
                else
                {
                    println("HTTP HTTP Request failed: \(error)")
                }
        }
        
    }

}


