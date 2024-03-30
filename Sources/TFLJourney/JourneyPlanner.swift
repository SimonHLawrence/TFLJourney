//
//  JourneyPlanner.swift
//  TFLJourney
//
//  Created by Simon Lawrence on 29/03/2024.
//

import Foundation
import OpenAPIRuntime

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
  
  public struct PointOfInterest: CustomStringConvertible {
    public var latitude: Double
    public var longitude: Double
    
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
  
  public func getJourneyPlan(from: PointOfInterest, to: PointOfInterest, via: PointOfInterest? = nil) async throws -> JourneyOutput {
    let path = Path(from: from.description, to: to.description)
    let query = Query(via: via?.description)
    let input: Input = Input(path: path, query: query)
    
    return try await client.Journey_JourneyResultsByPathFromPathToQueryViaQueryNationalSearchQueryDateQu(input)
  }
  
  public func getModes() async throws -> ModesOutput {
    
    return try await client.Journey_Meta()
  }
}
