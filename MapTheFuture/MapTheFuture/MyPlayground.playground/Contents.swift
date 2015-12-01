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











