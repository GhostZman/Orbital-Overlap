//
//  Orbital_OverlapTests.swift
//  Orbital OverlapTests
//
//  Created by Phys440Zachary on 2/28/24.
//

import XCTest

final class Orbital_OverlapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCoordinateConversions() throws {
        let myOrbital = Orbital()
        let x: Double = 1.0
        let y: Double = 1.0
        let z: Double = 2.0
        
        let sphericalCoords: [Double] = myOrbital.cartesianToSpherical(xCoordinate: x, yCoordinate: y, zCoordinate: z)
        
        XCTAssertEqual(sphericalCoords[0], 2.449489742, accuracy: 1.0E-7, "Was not equal to this resolution.")
        XCTAssertEqual(sphericalCoords[1], 0.615479708, accuracy: 1.0E-7, "Was not equal to this resolution.")
        XCTAssertEqual(sphericalCoords[2], 0.785398163, accuracy: 1.0E-2, "Was not equal to this resolution.")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
