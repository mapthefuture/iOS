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
    
    private var myManager = Manager()
    
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
    
    func putpic(image: UIImage, completion:(success: Bool)->()){
        
        // Update a User (PATCH https://fathomless-savannah-6575.herokuapp.com/user/7/update)
        
        guard let data = UIImagePNGRepresentation(image) else { return }
        
        let keychain = KeychainSwift()
        
        guard let id = keychain.get("id"), let token = keychain.get("token") where token.characters.count > 0
            
            else { return print("Couldn't get id or token")}
        
        print("token -> \(token)")
        

            /* Configure session, choose between:
            * defaultSessionConfiguration
            * ephemeralSessionConfiguration
            * backgroundSessionConfigurationWithIdentifier:
            And set session-wide properties, such as: HTTPAdditionalHeaders,
            HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
            */
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            
            /* Create session, and optionally set a NSURLSessionDelegate. */
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            /* Create the Request:
            Update a User (PATCH https://fathomless-savannah-6575.herokuapp.com/user/7/update)
            */
            
            let URL = NSURL(string: "https://fathomless-savannah-6575.herokuapp.com/user/7/update")
            let request = NSMutableURLRequest(URL: URL!)
            request.HTTPMethod = "PATCH"
            
            // Headers
            
            request.addValue("multipart/form-data; boundary=__X_PAW_BOUNDARY__", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "access_token")
            
            /* Start a new Task */
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("URL Session Task Failed: ", error);
                }
            })
            task.resume()
        }
    
    func urlRequestWithMultipartBody(urlString:String, parameters:NSDictionary) -> (URLRequestConvertible) {
        
        // Create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.PATCH.rawValue
        // Set Content-Type in HTTP header.
        let boundary = "PAW-boundary-\(arc4random())-\(arc4random())"
        let contentType = "multipart/form-data; boundary=" + boundary
        
        // Set data
        var dataString = String()
        dataString += "--\(boundary)"
        for (key, value) in parameters { dataString += "\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n--\(boundary)" }
        dataString += "--"
        
        let keychain = KeychainSwift()
        
        if let  token = keychain.get("token") where token.characters.count > 0 {

        
        // Set content-type
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        mutableURLRequest.setValue(token, forHTTPHeaderField:  "access_token")
        }
        
        // Set the HTTPBody we'd like to submit
        let requestBodyData = (dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        mutableURLRequest.HTTPBody = requestBodyData
        
        // return URLRequestConvertible
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0)
        
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
    
    
    
    func uploadPhoto2(photo: UIImage, completion:(success: Bool)->()) {
       
        
        print("about to upload photo")
        
        if let png =  UIImageJPEGRepresentation(photo, 0.5) {
            print("obtained photo")
            
            let base64string = png.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
            
            let keychain = KeychainSwift()
            
            guard let id = keychain.get("id"), let token = keychain.get("token") where token.characters.count > 0
                
                else { return print("Couldn't get id or token")}
            
            print("token -> \(token)")
            
            var headers = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
           
            headers["access_token"] = token
            headers["Content-Type"] = "application/json"
            
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = headers
            
            
            
            keychain.set(png, forKey: "profileImage")
            
            
            // JSON Body
            let bodyParameters = [
                "avatar": base64string
            ]
            
            let encoding = Alamofire.ParameterEncoding.JSON
            
            // Fetch Request
            myManager =  Alamofire
                .Manager(configuration: configuration)
            
                
            myManager.request(.PATCH, "https://fathomless-savannah-6575.herokuapp.com/user/\(id)/update", parameters: bodyParameters, encoding: encoding)
                .validate(statusCode: 200..<300).responseJSON(options: .MutableContainers, completionHandler: { (response) -> Void in
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
    

    
    func uploadPhoto(photo: UIImage, completion:(success: Bool)->()) {
        
        
        print("about to upload photo")
        
        if let png =  UIImageJPEGRepresentation(photo, 0.5) {
            print("obtained photo")
            
//            let base64string = png.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
            
        let keychain = KeychainSwift()
            
         guard let id = keychain.get("id"), let token = keychain.get("token") where token.characters.count > 0
            
            else { return print("Couldn't get id or token")}

            print("token -> \(token)")
            
            keychain.set(png, forKey: "profileImage")
            
            // Create manager
//            let manager = Manager.sharedInstance
            
            
           let headers = [
//                "Content-Type":"multipart/form-data; boundary=\(boundaryConstant)",
                "access_token": token
            ]
            
            
        
//  Alamofire.upload(.PATCH, "https://fathomless-savannah-6575.herokuapp.com/user/\(id)/update", headers: headers, data: png).responseJSON(completionHandler: { (response) -> Void in
//                
//                switch response.result{
//                case .Success(let value):
//                        print(value)
//                    completion(success: true)
//                case .Failure(let error):
//                    print(error)
//                    completion(success: false)
//                }
//            })

            Alamofire.upload(.PATCH, "https://fathomless-savannah-6575.herokuapp.com/user/\(id)/update", headers: headers, multipartFormData: { (multipartFormData) -> Void in
                
                multipartFormData.appendBodyPart(data: png, name:  "userID\(id)ProfilePhoto.png", mimeType: "image/png")
              
//                multipartFormData.appendBodyPart(data: "\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!, name: "")
//                 multipartFormData.appendBodyPart(data: "Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!, name: "")
//                
//                
//               
//                multipartFormData.appendBodyPart(data: "Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!, name: "")
//                multipartFormData.appendBodyPart(data: png, name: "")
                
                
                }, encodingMemoryThreshold: 10485760, encodingCompletion: { (encodeResult) -> Void in
                    
                    switch encodeResult {
                        
                    case .Failure(let error):
                        
                        print(error)
                        
                    case .Success(request: let request, streamingFromDisk: _, streamFileURL: _):
                       
                        request.responseJSON(options: .MutableContainers, completionHandler: { (response) -> Void in
                            
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
                    
                    //
            })
        }
        
}

//            Alamofire.upload(.PATCH, "https://fathomless-savannah-6575.herokuapp.com/user/\(id)/update", multipartFormData: { (multipartFormData) -> Void in
//                
//                multipartFormData.appendBodyPart(data: png, name: "userID\(id)ProfilePhoto")
//                
//                
//                }, encodingCompletion: { (encodingResult) -> Void in
//                    switch encodingResult {
//                    case .Failure(let error):
//                        print(error)
//                    case .Success(request: let request, streamingFromDisk: _, streamFileURL: _):
//                        print(request.response)
//                        
//                    }
//                })
//        }


class MyRequestController {
    
    static let sharedInstance = MyRequestController()
    
    func sendRequest(photo: UIImage) {
        
        
        if let png =  UIImageJPEGRepresentation(photo, 0.5) {
            print("obtained photo")
            
            let base64string = png.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
            
            let keychain = KeychainSwift()
            
            guard let id = keychain.get("id"), let token = keychain.get("token") where token.characters.count > 0
                
                else { return print("Couldn't get id or token")}
            
            print("token -> \(token)")

        /* Configure session, choose between:
        * defaultSessionConfiguration
        * ephemeralSessionConfiguration
        * backgroundSessionConfigurationWithIdentifier:
        And set session-wide properties, such as: HTTPAdditionalHeaders,
        HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
        */
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
        Update a User (PATCH https://fathomless-savannah-6575.herokuapp.com/user/7/update)
        */
        
        let URL = NSURL(string: "https://fathomless-savannah-6575.herokuapp.com/user/\(id)/update")
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "PATCH"
        
        // Headers
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "access_token")
        
        // Form URL-Encoded Body
        
        let bodyParameters = [
            "avatar": base64string
        ]
        let bodyString = self.stringFromQueryParameters(bodyParameters)
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        /* Start a new Task */
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error ) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: ", error);
            }
        })
        task.resume()
        }
    }
    
    /**
     This creates a new query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @param queryParameters The input dictionary.
     @return The created parameters string.
     */
    func stringFromQueryParameters(queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        for (name, value) in queryParameters {
            var part = NSString(format: "%@=%@",
                name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
                value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            parts.append(part as String)
        }
        return parts.joinWithSeparator("&")
    }
    
    /**
     Creates a new URL by adding the given query parameters.
     @param URL The input URL.
     @param queryParameters The query parameter dictionary to add.
     @return A new NSURL.
     */
    func NSURLByAppendingQueryParameters(URL : NSURL!, queryParameters : Dictionary<String, String>) -> NSURL {
        let URLString : NSString = NSString(format: "%@?%@", URL.absoluteString, self.stringFromQueryParameters(queryParameters))
        return NSURL(string: URLString as String)!
    }
}







