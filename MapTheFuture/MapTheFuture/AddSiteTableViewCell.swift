//
//  AddSiteTableViewCell.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/7/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit


class AddSiteTableViewCell: UITableViewCell {

  
    var mapItem: MKMapItem?
    var added = false {
        didSet {
            let view = UIImageView()
            view.frame.size = CGSize(width: 25, height: 25)
            
            
            view.contentMode = .ScaleAspectFit
            self.accessoryView = view
            
            if added {
                if let dark = UIImage(named: "addBlue") {
                    view.image = dark
                }
            } else if !added {
                if let light = UIImage(named:"addLight") {
                    view.image = light
                }
            }

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
       
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    

    }

}
