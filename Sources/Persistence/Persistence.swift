//
//  Persistence.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

@preconcurrency import AWSDynamoDB
import Foundation

/// Represents the data for an attribute. Each attribute value is described as a name-value pair.
/// The name is the data type, and the value is the data itself. For more information, see
/// [Data Types](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.NamingRulesDataTypes.html#HowItWorks.DataTypes)
/// in the Amazon DynamoDB Developer Guide.
public typealias AttributeValue = DynamoDBClientTypes.AttributeValue

/// A type that persists collections of attributes.
public struct Persistence: Sendable {
    /// A closure to modify the attributes of persisted values.
    ///
    /// Use this to add additional attributes like a timestamp or to perform validation of all
    /// persisted values.
    var attributeModifier: @Sendable ([String: AttributeValue]) throws -> [String: AttributeValue]

    /// A closure to create a new item or replace an old item with a new one.
    var put: @Sendable ([String: AttributeValue]) async throws -> Void

    /// Creates an instance.
    ///
    /// - Parameters:
    ///   - put: A closure to persist item attributes.
    ///   - attributeModifier: A closure to modify the attributes of all persisted values.
    public init(
        put: @escaping @Sendable ([String: AttributeValue]) async throws -> Void,
        attributeModifier: @escaping @Sendable ([String: AttributeValue]) throws -> [String: AttributeValue] = { $0 }
    ) {
        self.put = put
        self.attributeModifier = attributeModifier
    }

    /// Persists the given value.
    ///
    /// - Parameter contact: The value to persist.
    public func put<T: AttributeValueConvertible>(_ value: T) async throws {
        try await put(try attributeModifier(value.attributes))
    }
}

public extension Persistence {
    /// Returns an instance that adds a `CreatedAt` timestamp from the given `TimeStampProvider` to
    /// all persisted entities.
    ///
    /// - Parameters:
    ///   - timestampName: The name of the timestamp attribute.
    ///   - timestampProvider: A timestamp provider.
    ///   - put: A closure to persist item attributes.
    /// - Returns: A `Persistence` instance.
    static func addingTimestamp(
        named timestampName: String,
        from timestampProvider: TimestampProvider,
        put: @escaping @Sendable ([String: AttributeValue]) async throws -> Void
    ) -> Self {
        .init(
            put: put,
            attributeModifier: { $0.merging([timestampName: .s(timestampProvider.timestamp())]) { _, new in new } })
    }
}

/// A type that creates ``Persistence`` instances.
public struct PersistenceFactory: Sendable {
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
    /// - Parameter attributeModifier: A closure to modify the attributes of persisted values.
    static func live(
        attributeModifier: @escaping @Sendable ([String: AttributeValue]) throws -> [String: AttributeValue] = { $0 }
    ) -> Self {
        .init(make: { region, tableName in
            let dbClient = try DynamoDBClient(region: region)
            return Persistence(
                put: { _ = try await dbClient.putItem(input: PutItemInput(item: $0, tableName: tableName)) },
                attributeModifier: attributeModifier)
        })
    }
}
