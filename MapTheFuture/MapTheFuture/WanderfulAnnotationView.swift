//
//  WanderfulAnnotationView.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/12/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit
class WanderfulAnnotationView: MKAnnotationView {
    
     let defaultPinID = "com.macbellingrath.pin"
    

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        if let compassImage = UIImage(named: "wanderfulPin") {
            
            self.image = compassImage
            self.contentMode = .ScaleAspectFit
            
        }
       self.canShowCallout = true
       self.draggable = false
        
//        self.backgroundColor = UIColor.loblollyColor()
    
        self.rightCalloutAccessoryView  = UIButton(type: .InfoLight)
            
        self.frame.size = CGSize(width: 30, height: 30)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let compassImage = UIImage(named: "wanderfulPin") {
            
            self.image = compassImage
            self.contentMode = .ScaleAspectFit
            
        }
        
        self.canShowCallout = true
        self.draggable = false
        
        //        self.backgroundColor = UIColor.loblollyColor()
        
        self.rightCalloutAccessoryView  = UIButton(type: .InfoLight)
        
        self.frame.size = CGSize(width: 30, height: 30)

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
