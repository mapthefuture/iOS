//
//  SiteSectionHeaderTableViewCell.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/13/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

class SiteSectionHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var siteTitleLabel: UILabel!
    @IBOutlet weak var siteDescriptionLabel: UILabel!
    
    var site: Site? 
    
    @IBOutlet weak var moreButton: UIButton! {
        didSet {
            moreButton.layer.cornerRadius = moreButton.frame.height / 2
            moreButton.layer.masksToBounds = true
            moreButton.clipsToBounds = true
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setNeedsLayout()
        siteDescriptionLabel.text = site?.description ?? ""
        siteTitleLabel.text = site?.title ?? ""
        
        
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
