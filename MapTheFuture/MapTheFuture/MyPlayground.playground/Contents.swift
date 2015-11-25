//: Playground - noun: a place where people can play

import UIKit

infix operator >~ { associativity left }

func >~(tf: UITextField,count: Int) -> Bool {
    
    if tf.text?.characters.count > count {
        return true
    }
    return false
}

postfix operator >>> { }

postfix func >>>(tf: UITextField) -> Bool {
    
    if tf.text?.characters.count > 0 {
        return true
    }
    return false

}
postfix operator >* { }

postfix func >*(xs: [String]) -> Bool {
    
    let rs = xs.map{$0.characters.count > 0}
    if rs.contains(false) { return false }
    return true
    
}


let myfield = UITextField()
myfield.text = "Hello"

myfield >~ 1

myfield>>>

let s1 = "hi"
let s2 = "there"
let s3 = "f"
let arrayxs = [s1,s2,s3]


arrayxs>*





