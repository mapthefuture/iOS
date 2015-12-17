//
//  TourEditingViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/16/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import Eureka
import CoreLocation
import AlamofireImage

class TourEditingViewController: FormViewController {
    
    
    var tour: Tour?
    var sites: [Site] = []
    var siteIndex = 1
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let id = tour?.id ?? 0
        
        NetworkManager.sharedManager().getSitesforTour(id, completion: { (success, sites) -> () in
            self.sites = sites
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let id = tour?.id ?? 0
            
                   form
            
        +++ Section("Edit Tour")
        
            <<< TextRow("TourTitleTag") {
                $0.title = tour?.title
                
            }
            <<< TextRow("TourDescriptionTag"){
                $0.title = "Tour Description"
                $0.placeholder = tour?.description
                
            }
            
            <<< LocationRow("TourLocationTag") {
                $0.title = "Tour Start"
                if let lat = tour?.coordinate?.latitude, let lon = tour?.coordinate?.longitude {
                $0.value = CLLocation(latitude: lat, longitude: lon)
                } else {
                    $0.value = CLLocation()
                }
                
            }
        
         +++ Section("Sites")
            <<< ButtonRow("Done") {
                $0.title = $0.tag
                
                
            }.onCellSelection({ (cell, row) -> () in
                Loading.start()
                
                Loading.stop()
                
                
                self.alertUser("Done", message: "Update complete.")
//                let values = self.form.values()
//                
//                for i in 1...self.siteIndex {
//                    
//                    let siteLoc = values["SiteLocation\(i)"] as? CLLocation ?? CLLocation()
//                        
//                        let siteTitle = values["SiteTitle\(i)"] as? String ?? ""
//                        let siteDescription = values["SiteDescription\(i)"] as? String ?? ""
//                        let image = values["SiteImage\(i)"] as? UIImage
//                        
//                        let site = Site(tourID: id, title: siteTitle, coordinate: siteLoc.coordinate, description: siteDescription, image: image)
//                        
//                        self.sites.append(site)
//                        
//                    }
//                
//
//                for site in self.sites {
//                NetworkManager.sharedManager().updateSite(site, completion: { () -> () in
//                    print("updated")
//                    
//                    })
//                }
            })
        
        
        
//      sites.map { site in
//            
//            self.siteIndex++
//            
//            self.form.last!
//
//                    +++ Section("Site\(self.siteIndex)")
//                                
//                          form.last!  <<< TextRow("SiteTitle\(self.siteIndex)") {
//                                    $0.placeholder = site.title
//                                }
//                          form.last!       <<< ImageRow("SiteImage\(self.siteIndex)"){ siteImage in
//                                    siteImage.title = "Image"
//                                    //                        siteImage.value = UIImage().af_i
//                                    
//                                }
//                              form.last!   <<< TextAreaRow("SiteDescription\(self.siteIndex)") {
//                                    
//                                    $0.title = "Description"
//                                    $0.value = site.description
//                                }
//                              form.last!   <<< LocationRow("SiteLocation\(self.siteIndex)") {
//                                    
//                                    
//                                    $0.title = "Location"
//                                    
//                                    if let siteLat = site.coordinate?.latitude, let siteLong = site.coordinate?.longitude {
//                                        $0.value = CLLocation(latitude: siteLat , longitude: siteLong)
//                                    }
//                            }
//            
//                tableView?.reloadData()
//            }
//                tableView?.reloadData()
    
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
