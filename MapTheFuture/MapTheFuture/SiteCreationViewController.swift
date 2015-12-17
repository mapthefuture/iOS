//
//  SiteCreationViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/15/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import Eureka
import CoreLocation


class SiteCreationNavigationController: UINavigationController, RowControllerType {
    var completionCallback : ((UIViewController) -> ())?
}


class SiteCreationViewController: FormViewController, CLLocationManagerDelegate {
    
    var tour: Tour?
    
    var sites: [Site] = []
    var siteIndex = 1
    var responseSites: [Site] = []
    
    lazy var manager = CLLocationManager()
    
    var currentLoc = CLLocation()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.requestLocation()
        
        form +++ Section("Sites") {
            
            let header = HeaderFooterView<HeaderViewNib>(HeaderFooterProvider.NibFile(name: "WanderfulSectionHeader", bundle: nil))
            
            $0.header = header
            
        }
            <<< ButtonRow("Done") { done in
                done.title = done.tag
                
            
                done.onCellSelection({ (cell, row) -> () in
                    
                    self.createSites()
                  
                    guard let t = self.tour else { return print("No tour for self") }
                    
                    self.sites.map {
                      
                        NetworkManager.sharedManager().createSiteForTour2($0, tour: t, completion: { (success) -> () in
                            
                            if !success {
                            
                                self.alertUser("Couldn't upload sites.", message: "Try again.")
                                
                            } else if success {
                                
                                print("successfully uploaded")
                               
                                if let tourid = self.tour?.id, let lat = self.sites.first?.coordinate?.latitude, let lon = self.sites.first?.coordinate?.longitude {
                                   
                                    let params = [ "start_lat" : String(lat),  "start_lon": String(lon) ]
                                   
                                    NetworkManager.sharedManager().updateTour(tourid, params: params, success: { (success) -> () in
                                        
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    })
                                }
                            }
                        })
                    }
                })
        }

    
        form +++ Section("Add Sites")
            
            <<< ButtonRow("Add") { add in
                add.title = "Add Site"
                add.onCellSelection({ (cell, row) -> () in
                    
                      self.form
                        
                        +++ Section("Site \(self.siteIndex)")
                        
                        <<< TextRow("SiteTitle\(self.siteIndex)") {
                            $0.placeholder = "Site Title"
                        }
                        <<< ImageRow("SiteImage\(self.siteIndex)"){ siteImage in
                            siteImage.title = "Image"
                            
                        }
                        <<< TextAreaRow("SiteDescription\(self.siteIndex)") { $0.placeholder = "Provide a description"
                        }
                        <<< LocationRow("SiteLocation\(self.siteIndex)") {
                            $0.title = "Location"
                            
                            $0.value = self.currentLoc
                            
                        self.siteIndex++
                            
                    }

                })
        }
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func createSites() {
        print("pressed")
        
        guard let tour  = self.tour, let id = tour.id  else { return }
        
        print(tour, id)

        
        let values = self.form.values()
            
        for i in 1...self.siteIndex {
        
        if let siteLoc = values["SiteLocation\(i)"] as? CLLocation {
        
        let siteTitle = values["SiteTitle\(i)"] as? String ?? ""
        let siteDescription = values["SiteDescription\(i)"] as? String ?? ""
        let image = values["SiteImage\(i)"] as? UIImage
        
        let site = Site(tourID: id, title: siteTitle, coordinate: siteLoc.coordinate, description: siteDescription, image: image)
        
        self.sites.append(site)
            
            }
        }
    }
 
    func updatePhotos(forSites sites: [Site], completion: (Bool)->()) {
        
        for site in sites {
         site.uploadImage({ (success) -> () in
            print("Photo Uploaded for \(site): \(success)")
         })
        }
        completion(true)
        
    }

    func addSites() {
       
       form.last!
        
            +++ Section("Site\(siteIndex)")
        
            <<< TextRow("SiteTitle\(siteIndex)") {
            $0.placeholder = "Site Title"
            }
            <<< ImageRow("SiteImage"){ siteImage in
                siteImage.title = "Image"
                
            }
            <<< TextAreaRow("SiteDescription\(siteIndex)") { $0.placeholder = "Provide a description"
            }
            <<< LocationRow("SiteLocation\(siteIndex)") {
                
                
                $0.title = "Location"
                
                $0.value = self.currentLoc
                
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            self.currentLoc = loc
        }
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
