//
//  Models.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

import Foundation

/// An identifier for a sent email.
public typealias MessageID = String

/// The recipients of an email message.
public typealias Recipients = [String]

/// The sender of an email message.
public typealias Sender = String

/// The subject of an email message.
public typealias Subject = String

/// The body of an email message.
public enum Body: Codable, Equatable, Sendable {
    /// A message containing only text content.
    case text(String)
    /// A message containing only HTML content.
    case html(String)
    /// A message containing text and HTML content to support the widest variety of email clients.
    case combined(_ text: String, _ html: String)
}
