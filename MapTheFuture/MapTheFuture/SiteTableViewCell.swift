//
//  SiteTableViewCell.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/2/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import MapKit

class SiteTableViewCell: UITableViewCell, MKMapViewDelegate {
    
    @IBOutlet weak var siteTitleLabel: UILabel!
    
    @IBOutlet weak var siteDescriptionLabel: UILabel!
    
    @IBOutlet weak var siteImageView: UIImageView!
    @IBOutlet weak var siteMapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
