//
//  AWSDynamoDB+Utils.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

import AWSDynamoDB
import Foundation

public extension AttributeValue {
    /// Returns an attribute of type String with the `rawValue` of the given value.
    static func s<T: RawRepresentable>(_ value: T) -> Self where T.RawValue == String {
        .s(value.rawValue)
    }
}

public extension Dictionary where Key: CodingKey, Value == AttributeValue {
    /// Returns a dictionary mapping DynamoDB attribute values to table attributes.
    func attributeValues() -> [String: AttributeValue] {
        .init(uniqueKeysWithValues: map { ($0.stringValue.capitalizedFirstLetter(), $1) })
    }
}

public extension String {
    /// Returns a version of the string with the first letter capitalized.
    func capitalizedFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }
}
