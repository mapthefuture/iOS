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
import AlamofireImage

private let _sharedInstance = NetworkManager()

class NetworkManager: NSObject {
    
    typealias JSON = [String: AnyObject]
    private let base = "https://fathomless-savannah-6575.herokuapp.com/"
    
    class func sharedManager() -> NetworkManager {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["access_token" : KeychainSwift().get("token") ?? ""]
        return _sharedInstance
    }
    
    
    lazy var accesstokenHeader: [String: String]? = {
        let keychain = KeychainSwift()
        
        guard let token = keychain.get("token") where token.characters.count > 0
            
            else {print("Couldn't get id or token");
                
                
                return nil }
        
        print("token -> \(token)")
        

        
        return ["access_token" : token ]

    }()

    
    static let sharedInstance: NetworkManager = {
        let nm = NetworkManager()
        if let token = KeychainSwift().get("token") {
            print(token)
        
        // Create manager
        let manager = Manager.sharedInstance
        
        
        
        manager.session.configuration.HTTPAdditionalHeaders = [
            "token": token,
            "Content-Type":"application/json",
        ]
        }
        return nm

        
    }()
    
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
    func createTour(title: String, description: String, category: String, success:(Bool, Tour?)->()) {

        let URLParameters = [
            
            "title": title,
            "category" : category,
            "description" : description
        ]
        guard let headers = self.accesstokenHeader else {success(false, nil); return print("Couldn't get token") }
        
        // Fetch Request
        Alamofire.request(.POST, "https://fathomless-savannah-6575.herokuapp.com/tours/", parameters: URLParameters, encoding: ParameterEncoding.JSON, headers: headers).responseObject("tour", completionHandler: { (response: Response<Tour, NSError>) -> Void in
            switch response.result {
            
            case .Failure(let error):
                print(error)
                success(false, nil)
            case .Success(let tour):
                print(tour)
                success(true, tour)

            }
        })
 
    }
    
    /**
     Updates Tour
     
     - parameter id:      tour ID
     - parameter tour:    a tour with changes to update
     - parameter success: Callback
     */
    func updateTour(id: Int, params: [String : AnyObject], success:(Bool)->()) {
        
        guard let headers = self.accesstokenHeader else {success(false); return print("Couldn't get token") }
        
        // Fetch Request
        Alamofire.request(.PATCH, "https://fathomless-savannah-6575.herokuapp.com/tours/\(id)/", parameters: params, encoding: ParameterEncoding.JSON, headers: headers).responseObject("tour", completionHandler: { (response: Response<Tour, NSError>) -> Void in
            
            switch response.result {
                
            case .Failure(let error):
                print(error)
                success(false)
                
            case .Success(let tour):
                print(tour)
                success(true)
                
            }
        })
        
    }
    
    
    func deleteTour(tour: Tour, success: (Bool) -> ()) {
        guard let headers = self.accesstokenHeader, let id  = tour.id else { success(false); return print("Couldn't get token") }
        
        Alamofire.request(.DELETE, "https://fathomless-savannah-6575.herokuapp.com/tours/\(id)", parameters: nil, encoding: .JSON, headers: headers).responseString { (response) -> Void in
            switch response.result {
            case .Success(let value):
                print(value)
                success(true)
            case.Failure(let error):
                print(error)
                success(false)
            }
        }
        
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
    
    enum ModelType: String {
        case Tour, User, Site
    }
    enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }
    
    struct RequestType {
        var model: ModelType
        var method: Method
        var image: UIImage?
        var data: NSData?
        var recordID: Int?
    }
    
    lazy var imageCache: AutoPurgingImageCache = {
        return AutoPurgingImageCache()
    }()
    
    func downloadProfileImage(success:(Bool, UIImage?)->()) {
    
        guard let avURL = KeychainSwift().get("avatarURL") else { print("no Avatar URL"); return }
        
        Alamofire.request(.GET, avURL).responseImage { (response) -> Void in
            switch response.result {
            case .Failure(let error):
                print(error)
                success(false, nil)
            case .Success(let image):
                print("Successfully downloaded image")
                success(true, image)
                
            }
        }
    
    }
    
    func putpic(image: UIImage, completion:(success: Bool)->()){
        
        // Update a User (PATCH https://fathomless-savannah-6575.herokuapp.com/user/7/update)
        
//        guard let data = UIImagePNGRepresentation(image) else { return }
        
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
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
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
                
                NSURLSessionConfiguration.defaultSessionConfiguration().HTTPAdditionalHeaders = ["access_token":user.accessToken!]
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
        
//        guard let token = KeychainSwift().get("token") else { return }
//            
////            // Create manager
////            let manager = Manager.sharedInstance
////        
////        
////        
////            manager.session.configuration.HTTPAdditionalHeaders = [
////            "token": token,
////            "Content-Type":"application/json",
////            ]

            
            let encoding = Alamofire.ParameterEncoding.JSON
            // Fetch Request
        Alamofire.request(.GET, "https://fathomless-savannah-6575.herokuapp.com/tours/\(tourID)/sites", parameters: nil, headers: accesstokenHeader ,encoding: encoding).responseArray("sites") { (response: Response<[Site], NSError>) -> Void in
            
            switch response.result {
                
            case .Failure(let error):
                print("Error getting sites for tour \(error)")
                completion(success: false, sites: [])
            case .Success(let sites):
               _ =  sites.map{ print($0.title, $0.coordinate )}
                completion(success: true, sites: sites)
                
                }
            }
        }
    
    /**
     // Create Site 
     (POST https://fathomless-savannah-6575.herokuapp.com/tours/12/sites)
     
     - parameter tour:       A Tour objecect
     - parameter completion: called when the request completes
     */
    func createSiteforTour(site: Site, tour: Tour, completion:(success: Bool, Site?) -> ()) {
        //TODO
        guard let tourID = tour.id else { return print("Tour doesn't have id") }
        
        var URLParameters = ["":""]
        
        if let siteTitle = site.title { URLParameters["title"] = siteTitle }
        if let siteDescription = site.description { URLParameters["description"] = siteDescription }
        if let siteLatitude = site.coordinate?.latitude { URLParameters["latitude"] = String(siteLatitude) }
        if let siteLongitude = site.coordinate?.longitude { URLParameters["longitude"] = String(siteLongitude) }
        
       print(URLParameters)
        
        // Fetch Request
        Alamofire.request(.POST, "https://fathomless-savannah-6575.herokuapp.com/tours/\(tourID)/sites", parameters: URLParameters , encoding: ParameterEncoding.JSON, headers: accesstokenHeader).responseObject("site") { (response:
            Response<Site, NSError>) -> Void in
            switch response.result {
            case .Failure(let error):
                print(error)

                completion(success: false, nil)
            case .Success(let site):
                print(site)
                completion(success: true, site)
            }
            
        }
    }
    
    
    func updateSite(site: Site, completion: ()->()) {
        
        guard let siteID = site.id else { return print("Site doesn't have id") }
        
        var URLParameters = ["":""]
        
        if let siteTitle = site.title { URLParameters["title"] = siteTitle }
        if let siteDescription = site.description { URLParameters["description"] = siteDescription }
        if let siteLatitude = site.coordinate?.latitude { URLParameters["latitude"] = String(siteLatitude) }
        if let siteLongitude = site.coordinate?.longitude { URLParameters["longitude"] = String(siteLongitude) }
        
        print(URLParameters)
        
        // Fetch Request
        
        print("about to upload photo")
        
        
            
            
            
            let URL = NSURL(string: "https://fathomless-savannah-6575.herokuapp.com/sites/\(siteID)/sites")!
            var request = NSMutableURLRequest(URL: URL)
            
            
            let encoding = Alamofire.ParameterEncoding.URL
            (request, _) = encoding.encode(request, parameters: URLParameters)
            let urlstring = request.URLString
            
            
            //append parameters
            
            
            guard  let h = accesstokenHeader else { return }
        
            Alamofire.upload(.PATCH, urlstring, headers: h, multipartFormData: { (mpfd) -> Void in
                if let siteimg =  site.image, let png = UIImageJPEGRepresentation(siteimg, 0.5) {
                    print("obtained photo")
                    
                    
                    
                    let documentPath = getDocumentsDirectory()
                    
                    
                    let writePath = documentPath.stringByAppendingPathComponent("siteImage\(site.title ?? "").png")
                    png.writeToFile(writePath, atomically: true)
                    
                    let imageURL = NSURL(fileURLWithPath: writePath)

                mpfd.appendBodyPart(fileURL: imageURL, name: "image", fileName: "siteimage.png", mimeType: "image/png")
                }
                
                }, encodingMemoryThreshold: 10000, encodingCompletion: { (encodingResult) -> Void in
                    switch encodingResult {
                    case .Success(request: let request, streamingFromDisk: _, streamFileURL: _):
                        request.responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: { (response) -> Void in
                            print(response.response)
                            switch response.result {
                            case  .Failure(let error):
                                print(error)
                                completion()
                            case .Success(let value):
                                print(value)
                                completion()
                            }
                        })
                    case .Failure(let error):
                        print(error)
                        completion()
                    }
                    
                    
                    
            })
        }
        
    

    
    
    func uploadPhoto(photo: UIImage, completion:(success: Bool)->()) {
        
        
        print("about to upload photo")
        
        if let png =  UIImageJPEGRepresentation(photo, 0.5) {
            print("obtained photo")
            
            
        let keychain = KeychainSwift()
            
         guard let id = keychain.get("id"), let token = keychain.get("token") where token.characters.count > 0
            
            else { return print("Couldn't get id or token")}

            print("token -> \(token)")
            
            keychain.set(png, forKey: "profileImage")

            
            let documentPath = getDocumentsDirectory()
        
            let writePath = documentPath.stringByAppendingPathComponent("profileImage.png")
            png.writeToFile(writePath, atomically: true)
            
            
           
            let urlstring = "https://fathomless-savannah-6575.herokuapp.com/user/\(id)/update"
            guard  let h = accesstokenHeader else { return }
            let imageURL = NSURL(fileURLWithPath: writePath)
            
            Alamofire.upload(.PATCH, urlstring, headers: h, multipartFormData: { (mpfd) -> Void in
                
              mpfd.appendBodyPart(fileURL: imageURL, name: "avatar", fileName: "profileImage", mimeType: "image/png")
                
                
                }, encodingMemoryThreshold: 5000, encodingCompletion: { (encodingResult) -> Void in
                    switch encodingResult {
                    case .Success(request: let request, streamingFromDisk: _, streamFileURL: _):
                        request.responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: { (response) -> Void in
                            switch response.result {
                            case  .Failure(let error):
                                print(error)
                                completion(success: false)
                            case .Success(let value):
                                print(value)
                                completion(success: true)
                            }
                        })
                    case .Failure(let error):
                        print(error)
                    }
                    
                    
                    
                })
        }
    }
    
    
    func createSiteForTour2(site: Site, tour: Tour, completion: (Bool)->()) {
        guard let tourID = tour.id else { return print("Tour doesn't have id") }
        
        var URLParameters = ["":""]
        
        if let siteTitle = site.title { URLParameters["title"] = siteTitle }
        if let siteDescription = site.description { URLParameters["description"] = siteDescription }
        if let siteLatitude = site.coordinate?.latitude { URLParameters["latitude"] = String(siteLatitude) }
        if let siteLongitude = site.coordinate?.longitude { URLParameters["longitude"] = String(siteLongitude) }
        
        print(URLParameters)
        
        // Fetch Request
        
        print("about to upload photo")
        
        if let siteimg =  site.image, let png = UIImageJPEGRepresentation(siteimg, 0.5) {
            print("obtained photo")
            
            
            
            let documentPath = getDocumentsDirectory()
            
            
            let writePath = documentPath.stringByAppendingPathComponent("siteImage\(site.title ?? "").png")
            png.writeToFile(writePath, atomically: true)
            
            
            
            
            let URL = NSURL(string: "https://fathomless-savannah-6575.herokuapp.com/tours/\(tourID)/sites")!
            var request = NSMutableURLRequest(URL: URL)
            

            let encoding = Alamofire.ParameterEncoding.URL
            (request, _) = encoding.encode(request, parameters: URLParameters)
            let urlstring = request.URLString
            

            //append parameters
            
            
            guard  let h = accesstokenHeader else { return }
            let imageURL = NSURL(fileURLWithPath: writePath)
            
            Alamofire.upload(.POST, urlstring, headers: h, multipartFormData: { (mpfd) -> Void in
        
                mpfd.appendBodyPart(fileURL: imageURL, name: "image", fileName: "siteimage.png", mimeType: "image/png")
        
                
                }, encodingMemoryThreshold: 10000, encodingCompletion: { (encodingResult) -> Void in
                    switch encodingResult {
                    case .Success(request: let request, streamingFromDisk: _, streamFileURL: _):
                        request.responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: { (response) -> Void in
                            print(response.response)
                            switch response.result {
                            case  .Failure(let error):
                                print(error)
                                completion(false)
                            case .Success(let value):
                                print(value)
                                completion(true)
                            }
                        })
                    case .Failure(let error):
                        print(error)
                        completion(false)
                    }
                    
                    
                    
            })
        }
       
        
    }

    
    
    func uploadPhotoForSite(site: Site, photo: UIImage, completion:(success: Bool)->()) {
        
        
                print("about to upload photo")
                
                if let png =  UIImageJPEGRepresentation(photo, 0.5) {
                    print("obtained photo")
                    
                    
                    
                    let documentPath = getDocumentsDirectory()
                    
                    
                    let writePath = documentPath.stringByAppendingPathComponent("siteImage.png")
                    png.writeToFile(writePath, atomically: true)
                    
                    
                    
                    let urlstring = "https://fathomless-savannah-6575.herokuapp.com/sites/\(site.id!)/update"
                    guard  let h = accesstokenHeader else { return }
                    let imageURL = NSURL(fileURLWithPath: writePath)
                    
                    Alamofire.upload(.PATCH, urlstring, headers: h, multipartFormData: { (mpfd) -> Void in
                        
                        mpfd.appendBodyPart(fileURL: imageURL, name: "image", fileName: "image", mimeType: "image/png")

                        
                        }, encodingMemoryThreshold: 10000, encodingCompletion: { (encodingResult) -> Void in
                            switch encodingResult {
                            case .Success(request: let request, streamingFromDisk: _, streamFileURL: _):
                                request.responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: { (response) -> Void in
                                    switch response.result {
                                    case  .Failure(let error):
                                        print(error)
                                        completion(success: false)
                                    case .Success(let value):
                                        print(value)
                                        completion(success: true)
                                    }
                                })
                            case .Failure(let error):
                                print(error)
                                completion(success: false)
                            }
                            
                            
                            
                    })
                }
        }
}








