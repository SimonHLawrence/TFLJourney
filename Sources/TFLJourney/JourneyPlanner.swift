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
  public typealias Output = Journey.Output
  
  var transport: ClientTransport
  var client: Client
  
  public init(transport: ClientTransport) throws {
    self.transport = transport
    let configuration = Configuration(dateTranscoder: TFLDateTranscoder())
    client = try Client(serverURL: Servers.server1(), configuration: configuration, transport: transport)
  }
  
  public func planJourney(from: String, to: String, via: String? = nil) async throws -> Output {
    let path = Path(from: from, to: to)
    let query = Query(via: via)
    let input: Input = Input(path: path, query: query)
    
    return try await client.Journey_JourneyResultsByPathFromPathToQueryViaQueryNationalSearchQueryDateQu(input)
  }
}
