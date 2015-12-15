//
//  CreationViewController.swift
//  Wanderful
//
//  Created by Mac Bellingrath on 12/15/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import Eureka


class CreationNavigationController: UINavigationController, RowControllerType {
    var completionCallback : ((UIViewController) -> ())?
}

class CreationViewController: FormViewController {
    
    
    let categories = ["Nature", "Food", "Culture" , "Art", "History", "Architecture", "Other"]
    

    var tour: Tour?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section() {
            
            let header = HeaderFooterView<HeaderViewNib>(HeaderFooterProvider.NibFile(name: "WanderfulSectionHeader", bundle: nil))
            
            $0.header = header

        }
        
        
        form +++ Section("Tour Title")
        
            <<< TextRow("TitleTag") {
                $0.title = "Tour Title"
                $0.placeholderColor = UIColor.cinnabarColor()
        }
        
        form +++ Section("Tour Details")
            
        
            <<< AlertRow<String>("CategoryTag") {
                $0.title = "Category"
                $0.options = categories
                $0.value = "Other"
   
                }
       form +++ Section("Description")
        
        <<< TextAreaRow("DescriptionTag") { $0.placeholder = "Provide a description" }
        
        
        
        form +++ Section()
        
        <<< ButtonRow("Done") { row in
            row.title = row.tag
           
            row.onCellSelection({ (cell, row) -> () in
                
                print(self.form.values())
                
                let values = self.form.values()
                
                guard let tourTitle = values["TitleTag"] as? String, let tourDescription = values["DescriptionTag"] as? String, let tourCategory = values["CategoryTag"] as? String else { return }
                
                NetworkManager.sharedManager().createTour(tourTitle, description: tourDescription, category: tourCategory, success: { (success, tour) -> () in
                    
                    if !success  {
                        
                        self.alertUser("Couldn't create tour", message: "Something went wrong when creating this tour. Try again")
                        
                    } else if success {
                        
                        if let _tour = tour {
                            
                            self.tour = _tour
                            
                            self.performSegueWithIdentifier("AddSites", sender:     self)
                            }

                    
                        }
                
               
                    })
                })
            }
            
        
        <<< ButtonRow("Cancel") { row
            in row.title = row.tag
            row.onCellSelection({ (cell, row) -> () in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        }
  
    }

    func cancelTapped(barButtonItem: UIBarButtonItem) {
        (navigationController as? CreationNavigationController)?.completionCallback?(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard segue.identifier == "AddSites" else { return }
        guard let siteCreationVC = segue.destinationViewController as? SiteCreationViewController else { return }
        siteCreationVC.tour = self.tour
    }

}
