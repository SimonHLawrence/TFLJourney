//
//  TFLDateTranscoder.swift
//  TFLJourney
//
//  Created by Simon Lawrence on 29/03/2024.
//

import Foundation
import OpenAPIRuntime

/// Provides a date transcoder that will permit the multiple formats used by TFL (ISO8601 and dates with no timezone but fractional seconds are freely mixed).
public struct TFLDateTranscoder: DateTranscoder, @unchecked Sendable {
  
  /// The lock protecting the formatter.
  private let lock: NSLock
  
  /// The underlying date formatter.
  private let locked_formatter: DateFormatter
  private let fallback_formatter: ISO8601DateFormatter
  
  /// Creates a new transcoder.
  public init() {
    let nonISO8601Formatter = DateFormatter()
    nonISO8601Formatter.locale = Locale(identifier: "en_US_POSIX")
    nonISO8601Formatter.timeZone = TimeZone(abbreviation: "UTC")
    nonISO8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    fallback_formatter = ISO8601DateFormatter()
    fallback_formatter.formatOptions = [.withFractionalSeconds]
    lock = NSLock()
    lock.name = "com.akordo.tfljourney.runtime.TFLDateTranscoder"
    locked_formatter = nonISO8601Formatter
  }
  
  /// Creates and returns an ISO 8601 formatted string representation of the specified date.
  public func encode(_ date: Date) throws -> String {
    lock.lock()
    defer { lock.unlock() }
    return locked_formatter.string(from: date)
  }
  
  /// Creates and returns a date object from the specified ISO 8601 formatted string representation.
  public func decode(_ dateString: String) throws -> Date {
    lock.lock()
    defer { lock.unlock() }
    guard let date = locked_formatter.date(from: dateString) ?? fallback_formatter.date(from: dateString) else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: [], debugDescription: "Expected date string to be ISO8601-formatted.")
      )
    }
    return date
  }
}
