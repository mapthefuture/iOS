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
    
    var centerCoord: CLLocationCoordinate2D? {
        
        didSet {
            
            print(centerCoord)
            print(siteMapView)
            guard let centerCoord = centerCoord else { return }
            print(siteMapView.region)
            siteMapView.setRegion(MKCoordinateRegion(center: centerCoord, span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)), animated: true)
            print(siteMapView.region)
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
