//: Playground - noun: a place where people can play

import UIKit
import Foundation

let json: [String : AnyObject?] = [
    
    "tours" :
        [
            
            [
                "id": 1,
                "user_id": 2,
                "title": "Historical Views",
                "length": "4 hours"
            ],
            
            [
                "id": 2,
                "user_id": 1,
                "title": "A new side of Atlanta",
                "length": "2-4 hours"
            ],
            
            [
                "id": 3,
                "user_id": nil,
                "title": nil,
                "length": nil
            ],
            
            [
                "id": 4,
                "user_id": nil,
                "title": nil,
                "length": nil
            ],
            
            [
                "id": 5,
                "user_id": nil,
                "title": "Donuts in Brooklyn",
                "length": "1 hour"
            ]
    ]
]

let x = json["tours"]



//
//infix operator >~ { associativity left }
//
//func >~(tf: UITextField,count: Int) -> Bool {
//    
//    if tf.text?.characters.count > count {
//        return true
//    }
//    return false
//}
//
//postfix operator >>> { }
//
//postfix func >>>(tf: UITextField) -> Bool {
//    
//    if tf.text?.characters.count > 0 {
//        return true
//    }
//    return false
//
//}
//
//
//
//postfix operator >* { }
//
//postfix func >*(xs: [String]) -> Bool {
//    
//    let rs = xs.map{$0.characters.count > 0}
//    if rs.contains(false) { return false }
//    return true
//    
//}
//
//
//
//let me = ["mac"]
//
//me>*



//infix operator <*> { associativity left }
//
//func <*><T: Equatable>(lhs: T, rhs: T) -> Bool {
//    if lhs === rhs {
//        return true
//    }
//    return false
//}
//
//
//func ***(lhs: )






//let myfield = UITextField()
//myfield.text = "Hello"
//
//myfield >~ 1
//
//myfield>>>
//
//let s1 = "hi"
//let s2 = "there"
//let s3 = "f"
//let arrayxs = [s1,s2,s3]
//
//
//arrayxs>*





class MyRequestController {
    
    func sendRequest() {
        
        // Update a User (PATCH https://fathomless-savannah-6575.herokuapp.com/user/7/update)
        
        // Create manager
        var manager = Manager.sharedInstance
        
        // Add Headers
        manager.session.configuration.HTTPAdditionalHeaders = [
            "Content-Type":"multipart/form-data; boundary=__X_PAW_BOUNDARY__",
            "access_token":"c80ad01a14a0a6710584bbe457d74e8d",
        ]
        // Form Multipart Body
        let bodyParameters = [
            "avatar":"sdfg",
        ]
        
        Alamofire.request(urlRequestWithMultipartBody("https://fathomless-savannah-6575.herokuapp.com/user/7/update", parameters: bodyParameters))
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
    
    
    func urlRequestWithMultipartBody(urlString:String, parameters:NSDictionary) -> (URLRequestConvertible) {
        
        // Create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        // Set Content-Type in HTTP header.
        let boundary = "PAW-boundary-\(arc4random())-\(arc4random())"
        let contentType = "multipart/form-data; boundary=" + boundary
        
        // Set data
        var dataString = String()
        dataString += "--\(boundary)"
        for (key, value) in parameters { dataString += "\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n--\(boundary)" }
        dataString += "--"
        
        // Set content-type
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Set the HTTPBody we'd like to submit
        let requestBodyData = (dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        mutableURLRequest.HTTPBody = requestBodyData
        
        // return URLRequestConvertible
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0)
    }
}







