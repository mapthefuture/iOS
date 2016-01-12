//
//  WanderfulTests.swift
//  WanderfulTests
//
//  Created by Mac Bellingrath on 1/12/16.
//  Copyright © 2016 Mac Bellingrath. All rights reserved.
//

import XCTest
@testable import Wanderful

extension UIViewController {
    
    func preloadView() {
        let _ = self.view
        
    }
}

class WanderfulTests: XCTestCase {
    
    var mainVC: MainViewController?
    
    override func setUp() {
        super.setUp()
       mainVC = MainViewController()
       mainVC?.loadView()
    }

    func testNetworkManagerGETTours() {
        let manager = NetworkManager()
        manager.getAllTours { (success, tours) -> () in
            print(tours)
            XCTAssert(tours.count > 0)
        }
    }
    
           
}
