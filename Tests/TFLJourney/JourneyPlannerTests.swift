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
    static let londonWaterloo = JourneyPlanner.PointOfInterest(latitude: 51.5032, longitude: -0.1123)
    static let londonVictoria = JourneyPlanner.PointOfInterest(latitude: 51.4952, longitude: -0.1439)
    static let claphamJunction = JourneyPlanner.PointOfInterest(latitude: 51.4652, longitude: -0.1708)
  }
  
  func testDateTranscoder() throws {
    
    let transcoder = TFLDateTranscoder()
    let decodedDate = try? transcoder.decode("2024-03-29T14:51:32")
    XCTAssertNotNil(decodedDate)
    if let decodedDate {
      if let encodedDate = try? transcoder.encode(decodedDate) {
        let roundTrippedDate = try transcoder.decode(encodedDate)
        XCTAssertEqual(decodedDate, roundTrippedDate)
      }
    }
    XCTAssertNotNil(try? transcoder.decode("2024-03-29T14:51:32.005Z"))
  }
  
  func testGetJourneyPlan() async throws {
    let transport = URLSessionTransport()
    let journeyPlanner = try JourneyPlanner(transport: transport)
    
    let output = try await journeyPlanner.getJourneyPlan(from: WellKnownCoordinates.claphamJunction,
                                                         to: WellKnownCoordinates.londonVictoria,
                                                         via: WellKnownCoordinates.londonWaterloo,
                                                         leavingAt: Date.now)
    
    XCTAssertNoThrow(try output.ok)
  }
  
  func testGetModes() async throws {
    let transport = URLSessionTransport()
    let journeyPlanner = try JourneyPlanner(transport: transport)
    
    let output = try await journeyPlanner.getModes()
    
    guard
      let output = try? output.ok,
      let jsonOutput = try? output.body.json
    else {
      XCTFail("Operation failed.")
      return
    }
    
    XCTAssertFalse(jsonOutput.isEmpty)
  }
}
