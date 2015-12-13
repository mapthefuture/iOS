//
//  SiteDetailViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/13/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

class SiteDetailViewController: UIViewController {
    
    @IBOutlet weak var siteTitleLabel: UILabel! {
        didSet {
            configure()

        }
    }
    
    var site: Site? {
        didSet {
           configure()
        }
    }
    func configure() {
        if let label = self.siteTitleLabel {
            label.text = site?.title
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
