//
//  TimestampProvider.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

import Foundation

/// A class of types providing user-readable representations of dates.
public protocol DateFormatting: Sendable {
    /// Returns a string representation of the specified date.
    ///
    /// - Parameter date: The date to be represented.
    /// - Returns: A user-readable string representing the date.
    func string(from date: Date) -> String
}

extension DateFormatter: DateFormatting {
    public static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

/// A type to provide timestamps.
public struct TimestampProvider: Sendable {
    private let dateProvider: @Sendable () -> Date
    private let formatter: any DateFormatting

    /// Creates an instance.
    ///
    /// - Parameters:
    ///   - dateProvider: A closure returning the current date.
    ///   - formatter: The date formatter to use to format the current date.
    public init(
        dateProvider: @escaping @Sendable () -> Date,
        formatter: DateFormatting
    ) {
        self.dateProvider = dateProvider
        self.formatter = formatter
    }

    /// Returns a timestamp.
    public func timestamp() -> String {
        formatter.string(from: dateProvider())
    }
}

public extension TimestampProvider {
    /// A live implementation.
    static var live: Self {
        .init(
            dateProvider: { Date() },
            formatter: DateFormatter.iso8601)
    }
}
