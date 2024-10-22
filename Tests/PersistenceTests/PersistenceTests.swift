//
//  PersistenceTests.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

@testable import Persistence
import Foundation
import XCTest

final class PersistenceTests: XCTestCase {

    struct Model: Codable, Equatable, AttributeValueConvertible {
        let bool: Bool
        let string: String

        var attributes: [String: AttributeValue] {
            let values: [CodingKeys: AttributeValue] = [
                .bool: .bool(bool),
                .string: .s(string)
            ]
            return values.attributeValues()
        }
    }

    let timeoutInterval: TimeInterval =  0.1

    func testPersistence() async throws {
        let expected: [String: AttributeValue] = [
            "Bool": .bool(true),
            "CreatedAt": .s("1970-01-01T00:00:00Z"),
            "String": .s("string")
        ]

        let timestampProvider = TimestampProvider(
            dateProvider: { Date(timeIntervalSince1970: 0) },
            formatter: DateFormatter.iso8601)

        let expectation = expectation(description: "Model persisted")
        let sut = Persistence.addingTimestamp(named: "CreatedAt", from: timestampProvider) { actual in
            XCTAssertEqual(actual, expected)
            expectation.fulfill()
        }

        try await sut.put(Model(bool: true, string: "string"))
        await fulfillment(of: [expectation], timeout: timeoutInterval)
    }
}
