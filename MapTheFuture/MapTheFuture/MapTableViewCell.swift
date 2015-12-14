//
//  MapTableViewCell.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 12/1/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit


class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var tourTitleLabel: UILabel!
    
    @IBOutlet weak var tourDescriptionLabel: UILabel!
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    @IBOutlet weak var myTourView: UIView!
    
    var myTour = false
        {
        didSet {
            if myTour == true {
                myTourView.backgroundColor = UIColor.unitedNationsBlue()
                
            } else {
                myTourView.backgroundColor = UIColor.loblollyColor()
            }
             self.contentView.setNeedsDisplay()
        }
       
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
      

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
