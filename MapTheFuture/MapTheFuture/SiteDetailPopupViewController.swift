//
//  SiteDetailPopupViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/14/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import STPopup
import AlamofireImage
class SiteDetailPopupViewController: UIViewController {
   
    @IBOutlet weak var imgView: UIImageView! {
        didSet {

            if let s = site, let url = s.imageURL, let ns = NSURL(string: url) {
                if s.hasImage() {
                    imgView.af_setImageWithURL(ns, placeholderImage: nil, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: imgView.frame.size, radius: 5), imageTransition: .FlipFromTop(1))
                    

                }
            }
        }
    }
    
    @IBOutlet weak var tourDescription: UITextView! {
        didSet {
            tourDescription.text = site?.description ?? site?.title
        }
    }
    
    var large = false
  
    @IBOutlet weak var imageButton: UIButton! {
        didSet {
            if let url = site?.imageURL{
                if url.containsString("missing") {
                    imageButton.enabled = false
                    imageButton.hidden = true
                    
                    
                }

                
            }
        }
    }
    
    @IBOutlet weak var audioButton: UIButton! {
        didSet {
            if let url = site?.audioURL{
                if url.containsString("missing") {
                    audioButton.enabled = false
                    audioButton.hidden = true
                }
                
                
            }
        }
    }
    
    
    @IBOutlet weak var noteButton: UIButton!
    
    //Button Outlets
    
    var site: Site? {
        didSet {
            print("site Set", site, site?.title)
            self.title = site?.title
            self.navigationItem.title = site?.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentSizeInPopup = CGSizeMake(300, 400);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
        
        if let s = site, let url = s.imageURL, let ns = NSURL(string: url) {
            if s.hasImage() {
                print("hasimage!", s.hasImage())
                imgView.af_setImageWithURL(ns)
                imgView.af_setImageWithURL(ns, placeholderImage: nil, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: imgView.frame.size, radius: 20), imageTransition: .FlipFromTop(1))
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = site?.title
        self.contentSizeInPopup = CGSizeMake(300, 400)
        self.landscapeContentSizeInPopup = CGSize(width: 300, height: 400)
        
      
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = site?.title
        self.contentSizeInPopup = CGSizeMake(300, 400)
        self.landscapeContentSizeInPopup = CGSize(width: 300, height: 400)
        
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
