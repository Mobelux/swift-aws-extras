//
//  Persistence.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

import AWSDynamoDB
import Foundation

/// Represents the data for an attribute. Each attribute value is described as a name-value pair.
/// The name is the data type, and the value is the data itself. For more information, see
/// [Data Types](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.NamingRulesDataTypes.html#HowItWorks.DataTypes)
/// in the Amazon DynamoDB Developer Guide.
public typealias AttributeValue = DynamoDBClientTypes.AttributeValue

/// A type that persists collections of attributes.
public struct Persistence {
    /// A closure to create a new item or replace an old item with a new one.
    var put: @Sendable ([String: AttributeValue]) async throws -> Void

    /// Creates an instance.
    ///
    /// - Parameter put: A closure to persist item attributes.
    public init(
        put: @escaping @Sendable ([String: AttributeValue]) async throws -> Void
    ) {
        self.put = put
    }

    /// Persists the given value.
    ///
    /// - Parameter contact: The value to persist.
    public func put<T: AttributeValueConvertible>(_ value: T) async throws -> Void {
        try await put(value.attributes)
    }
}

/// A type that creates ``Persistence`` instances.
public struct PersistenceFactory {
    /// The region where the table is located.
    public typealias Region = String

    /// The name of the table.
    public typealias TableName = String

    /// A closure that creates and returns a ``Persistence`` instance.
    public var make: @Sendable (Region, TableName) throws -> Persistence

    /// Creates an instance.
    ///
    /// - Parameter make: A closure returning a ``Persistence`` instance.
    public init(
        make: @escaping @Sendable (Region, TableName) throws -> Persistence
    ) {
        self.make = make
    }
}

public extension PersistenceFactory {
    /// Returns a live implementation.
    ///
    /// - Parameter attributeProvider: An optional closure returning additional attributes to any
    /// values that are persisted.
    static func live(
        additionalAttributes attributeProvider: (() throws -> [String: AttributeValue])? = nil
    ) -> Self {
        .init(make: { region, tableName in
            let dbClient = try DynamoDBClient(region: region)

            let inputProvider: ([String: AttributeValue]) throws -> PutItemInput
            if let attributeProvider {
                inputProvider = { attributes in
                    PutItemInput(
                        item: try attributes.merging(attributeProvider()) { (_, new) in new },
                        tableName: tableName
                    )
                }
            } else {
                inputProvider = { PutItemInput(item: $0, tableName: tableName) }
            }

            return Persistence(put: { _ = try await dbClient.putItem(input: inputProvider($0)) })
        })
    }
}
