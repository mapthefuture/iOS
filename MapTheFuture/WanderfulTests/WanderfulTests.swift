//
//  WanderfulTests.swift
//  WanderfulTests
//
//  Created by Mac Bellingrath on 1/12/16.
//  Copyright © 2016 Mac Bellingrath. All rights reserved.
//

import XCTest
@testable import Wanderful

class WanderfulTests: XCTestCase {

    func testNetworkManagerGETTours() {
        let manager = NetworkManager()
        manager.getAllTours { (success, tours) -> () in
            XCTAssert(tours.count > 0)
        }
    }
        
}
