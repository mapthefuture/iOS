
import XCTest
import MapKit
@testable import Wanderful

class MockRoute: MKRoute {
    override var distance: CLLocationDistance {
        return 5.0 }
    
}
class ExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCalculatetetimeEstimate() {
        let route = MKRoute()
        let timeEstimate = calculateTimeEstimateStringFrom([route])
        XCTAssertEqual(timeEstimate, "00:00", "Function should return string representing zero time aka \"00:00\"")
        
    }
    func testCalculateTotalDistanceFromRoutes() {
        let route = MockRoute()
        let totalDistance = calculateTotalDistanceFrom([route])
        XCTAssertTrue(totalDistance == 5.0)
        
        
    }
    
    func testCalculateTimeEstimateStringFromRoutes() {
        let r = MockRoute()
        let timeEstimateString = calculateTimeEstimateStringFrom([r])
        XCTAssertEqual(timeEstimateString, "00:00")
        
        
    }
    
}

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