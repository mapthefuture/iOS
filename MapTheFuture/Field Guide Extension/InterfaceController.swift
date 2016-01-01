//
//  InterfaceController.swift
//  Field Guide Extension
//
//  Created by Mac Bellingrath on 1/1/16.
//  Copyright © 2016 Mac Bellingrath. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
  
    @IBOutlet var tourTitleLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if WCSession.isSupported(){
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    
    
        
    }
    private var session: WCSession?
    private static let rowID = "MainRowType"

    @IBOutlet var table: WKInterfaceTable!
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    enum TourDictKey: String {
        case TourTitle, TourTime, TourDistance, MetersToMilesString, TimeEstimate
    }
    
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        print(message)
        tourTitleLabel.setText(message[TourDictKey.TourTitle.rawValue] as? String)
        
        
        
    }
   
//    func configureTable() {
//    // Fetch the to-do items
//////    let items = self.fetchTodoList()
////    
////    // Configure the table object and get the row controllers.
////    self.todoListTable.setNumberOfRows(items.count, withRowType: rowID)
////    letrowCount = self.todoListTable.numberOfRows
////    
////    // Iterate over the rows and set the label and image for each one.
////    for (vari = 0; i < rowCount; i++) {
////    // Set the values for the row controller
////    letrow = self.todoListTable.rowControllerAtIndex(i) as! MyRowController
////    
////    row.itemImage.setImage(items[i].image)
////    row.itemLabel.setText(items[i].title)
////    }
////    }

}
