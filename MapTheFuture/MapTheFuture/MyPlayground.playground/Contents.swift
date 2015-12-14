//: Playground - noun: a place where people can play

import UIKit
import Foundation

let distances = [0.0, 52.6048482237498, 7640713.6897714, 12430797.0004833, 30.5710683316783, 931.603764687175, 1235369.17415889, 941.011627370927, 557.039838632262, 2484.88839521014, 12430797.0004833, 127.435363458856, 7640713.6897714]
//Distance Conversions
extension Double {
    func metersToMiles() -> Double {
        let miles = (round(1000 * (self * 0.000621371)) / 1000)
        return miles
    }
    
    func metersToMilesString() -> String {
        let miles = (round(1000 * (self * 0.000621371)) / 1000)
        
        switch miles {
        case let x where x == 0:  return "Distance Unknown"
        case let x where x <= 0.25: return "Less than a quarter mile"
        case let x where x <= 0.5:  return "Less than half of a mile"
        case let x where x <= 1.0:  return "Less than a mile"
        case let x where x > 1.0: return "About \(x) miles"
        default: return "Distance Unknown"
            
        }
    }
}

public extension SequenceType {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    
    func categorise<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            dict[key]?.append(el) ?? {dict[key] = [el]}()
        }
        return dict
    }
}

let x = distances.categorise { $0.metersToMilesString()}
x.count


extension Double {

    func titleFromDouble() -> String {
       
    
    let miles = (round(1000 * (self * 0.000621371)) / 1000)
            switch miles {
            case let x where x >= 0 && x <= 1 : return "Less than one mile"
            case let x where x > 1 && x <= 5 : return "One to five miles"
            case let x where x > 5 && x <= 10: return "Five to ten miles"
            case let x where x > 10 && x <= 20: return "Ten to twenty miles"
            case let x where x > 20 && x <= 50: return "Twenty to fifty miles"
            case let x where x > 50: return "Far Away"
            default: return "Unknown"
           
            }
    }
}

for x in distances {
    print(x.titleFromDouble())
}
let so = distances.categorise{$0.titleFromDouble()}
so["Far Away"]














