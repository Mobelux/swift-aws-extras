//
//  SecretValue.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/22/23.
//

import AWSSecretsManager
import Foundation

/// A class of types providing secrets.
protocol SecretValue: Equatable {
    /// The ARN of the secret.
    var arn: String? { get }

    /// The friendly name of the secret.
    var name: String? { get }

    /// The decrypted secret value, if the secret value was originally provided as binary data in
    /// the form of a byte array.
    ///
    /// If the secret was created by using the Secrets Manager console, or if the secret value was
    /// originally provided as a string, then this field is omitted. The secret value appears in
    /// `SecretString` instead.
    var secretBinary: Data? { get }

    /// The decrypted secret value, if the secret value was originally provided as a string or
    /// through the Secrets Manager console.
    ///
    /// If this secret was created by using the console, then Secrets Manager stores the information
    /// as a JSON structure of key/value pairs.
    var secretString: String? { get }
}

extension GetSecretValueOutput: @retroactive Equatable {
    public static func == (lhs: GetSecretValueOutput, rhs: GetSecretValueOutput) -> Bool {
        lhs.arn == rhs.arn
        && lhs.name == rhs.name
        && lhs.secretBinary == rhs.secretBinary
        && lhs.secretString == rhs.secretString
    }
}
extension GetSecretValueOutput: SecretValue {}

extension SecretsManagerClientTypes.SecretValueEntry: @retroactive Equatable {
    public static func == (lhs: SecretsManagerClientTypes.SecretValueEntry, rhs: SecretsManagerClientTypes.SecretValueEntry) -> Bool {
        lhs.arn == rhs.arn
        && lhs.name == rhs.name
        && lhs.secretBinary == rhs.secretBinary
        && lhs.secretString == rhs.secretString
    }
}
extension SecretsManagerClientTypes.SecretValueEntry: SecretValue {}
