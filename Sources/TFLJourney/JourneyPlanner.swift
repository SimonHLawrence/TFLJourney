//
//  JourneyPlanner.swift
//  TFLJourney
//
//  Created by Simon Lawrence on 29/03/2024.
//

import Foundation
import OpenAPIRuntime

/// A simple wrapper for the TFL Journey Planner API.
/// See https://api.tfl.gov.uk/swagger/ui/index.html?url=/swagger/docs/v1#!/Journey/Journey_Meta and
/// https://api.tfl.gov.uk/swagger/ui/index.html?url=/swagger/docs/v1#!/Journey/Journey_JourneyResults for documentation.
public class JourneyPlanner {
  
  public typealias Journey = Operations.Journey_JourneyResultsByPathFromPathToQueryViaQueryNationalSearchQueryDateQu
  typealias Input = Journey.Input
  typealias Query = Input.Query
  typealias Path = Input.Path
  public typealias JourneyOutput = Journey.Output
  public typealias Modes = Operations.Journey_Meta
  public typealias ModesOutput = Modes.Output
  
  var transport: ClientTransport
  var client: Client
  
  /// A structure representing a journey point.
  public struct PointOfInterest: CustomStringConvertible {
    public var latitude: Double
    public var longitude: Double
    
    /// Initialize a new journey point.
    /// - Parameters:
    ///   - latitude: the latitude, in degrees.
    ///   - longitude: the longitude in degrees.
    public init(latitude: Double, longitude: Double) {
      self.latitude = latitude
      self.longitude = longitude
    }
    
    public var description: String {
      "\(latitude),\(longitude)"
    }
  }
  
  public init(transport: ClientTransport) throws {
    self.transport = transport
    let configuration = Configuration(dateTranscoder: TFLDateTranscoder())
    client = try Client(serverURL: Servers.server1(), configuration: configuration, transport: transport)
  }
  
  /// Get a journey plan for the specified points and optional deparure time.
  /// - Parameters:
  ///   - from: the starting point of the journey.
  ///   - to: the destination of the journey.
  ///   - via: an optional point to travel through.
  ///   - leavingAt: the time today at which to leave. Note that the date part is ignored.
  /// - Returns: A set of journey plans for the recommended routes.
  public func getJourneyPlan(from: PointOfInterest, to: PointOfInterest, via: PointOfInterest? = nil, leavingAt: Date? = nil) async throws -> JourneyOutput {
    let path = Path(from: from.description, to: to.description)
    var time: String?
    var timeIsPayload: Query.timeIsPayload?
    if let leavingAt {
      let timeFormatter = DateFormatter()
      timeFormatter.locale = Locale(identifier: "en_US_POSIX")
      timeFormatter.timeZone = TimeZone(abbreviation: "UTC")
      timeFormatter.dateFormat = "HHmm"
      
      time = timeFormatter.string(from: leavingAt)
      timeIsPayload = .Departing
    }
    let query = Query(via: via?.description, time: time, timeIs: timeIsPayload)
    let input: Input = Input(path: path, query: query)
    
    return try await client.Journey_JourneyResultsByPathFromPathToQueryViaQueryNationalSearchQueryDateQu(input)
  }
  
  /// Get the available transport modes such as walking, national rail, tube etc.
  /// - Returns: A list of available modes.
  public func getModes() async throws -> ModesOutput {
    return try await client.Journey_Meta()
  }
}
