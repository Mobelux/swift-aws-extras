//
//  AttributeValueConvertible.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

import AWSDynamoDB
import Foundation

/// A type that may be represented by a mapping of attribute names to values for use with DynamoDB.
public protocol AttributeValueConvertible {
    /// A representation of this instance mapping attribute names to attribute values.
    var attributes: [String: AttributeValue] { get }
}
