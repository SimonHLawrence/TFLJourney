//
//  JourneyPlannerTests.swift
//  
//
//  Created by Simon Lawrence on 29/03/2024.
//

import XCTest
import OpenAPIRuntime
import OpenAPIURLSession
@testable import TFLJourney

final class JourneyPlannerTests: XCTestCase {
  
  struct WellKnownCoordinates {
    static let londonWaterloo = "51.5032,-0.1123"
    static let londonVictoria = "51.4952,-0.1439"
    static let claphamJunction = "51.4652,-0.1708"
  }
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  
  func testDate() throws {
    
    let transcoder = TFLDateTranscoder()
    XCTAssertNotNil(try? transcoder.decode("2024-03-29T14:51:32"))
    XCTAssertNotNil(try? transcoder.decode("2024-03-29T14:51:32.005Z"))
  }
  
  func testJourneyPlanner() async throws {
    let transport = URLSessionTransport()
    let journeyPlanner = try JourneyPlanner(transport: transport)
    
    let output = try await journeyPlanner.planJourney(from: WellKnownCoordinates.claphamJunction,
                                                      to: WellKnownCoordinates.londonVictoria,
                                                      via: WellKnownCoordinates.londonWaterloo)
    
    XCTAssertNotNil(output)
  
    print(output)
  }
}
