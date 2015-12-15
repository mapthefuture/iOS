//
//  SiteSectionHeaderTableViewCell.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/13/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import AlamofireImage

class SiteSectionHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var siteTitleLabel: UILabel!
    @IBOutlet weak var siteDescriptionLabel: UILabel!
    
    var site: Site? 
    
    @IBOutlet weak var cameraIcon: UIImageView!
    
    @IBOutlet weak var audioIcon: UIImageView!
    
    @IBOutlet weak var noteIcon: UIImageView!

    @IBOutlet weak var imageV: UIImageView!
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setNeedsLayout()
        siteDescriptionLabel.text = site?.description ?? ""
        siteTitleLabel.text = site?.title ?? ""
        if let s = site, let url = s.imageURL, let _nsimgurl = NSURL(string: url) {
            if s.hasImage() {
                imageV.af_setImageWithURL(_nsimgurl)
            }
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
