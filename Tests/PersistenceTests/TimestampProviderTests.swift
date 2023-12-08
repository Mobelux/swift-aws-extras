//
//  TimestampProviderTests.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

import Foundation

@testable import Persistence
import Foundation
import XCTest

final class TimestampProviderTests: XCTestCase {
    func testTimestamp() {
        let expected = "1970-01-01T00:00:00Z"

        let sut = TimestampProvider(
            dateProvider: { Date(timeIntervalSince1970: 0) },
            formatter: ISO8601DateFormatter())
        let actual = sut.timestamp()
        XCTAssertEqual(actual, expected)
    }
}
