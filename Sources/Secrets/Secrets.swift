//
//  Secrets.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/22/23.
//

import AWSSecretsManager
import Foundation

/// A secret stored by AWS Secrets Manager.
public struct Secret {

    /// A secret stored by AWS Secrets Manager.
    public enum Value {
        /// The decrypted secret value, if the secret value was originally provided as binary data in
        /// the form of a byte array.
        case binary(Data)
        /// The decrypted secret value, if the secret value was originally provided as a string or
        /// through the Secrets Manager console.
        ///
        /// If this secret was created by using the console, then Secrets Manager stores the information
        /// as a JSON structure of key/value pairs.
        case string(String)
    }

    /// The ARN of the secret.
    var arn: String

    /// The friendly name of the secret.
    var name: String

    /// The decrypted secret value.
    var value: Value

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - arn: The ARN of the secret.
    ///   - name: The friendly name of the secret.
    ///   - value: The decrypted secret value.
    public init(arn: String, name: String, value: Value) {
        self.arn = arn
        self.name = name
        self.value = value
    }
}

extension Secret {
    /// Creates a new intance.
    ///
    /// - Parameter secretValue: A secret value.
    init<V: SecretValue>(_ secretValue: V) throws {
        guard let arn = secretValue.arn, let name = secretValue.name else {
            throw SecretsError.missingData
        }

        self.arn = arn
        self.name = name
        if let string = secretValue.secretString  {
            self.value = .string(string)
        } else if let data = secretValue.secretBinary {
            self.value = .binary(data)
        } else {
            throw SecretsError.missingData
        }
    }
}

/// An error that can be thrown when retrieving secrets.
public enum SecretsError: LocalizedError {
    /// The secret is missing expected data.
    case missingData
    /// The decrypted secret is of an unexpected type.
    case wrongSecretType

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .missingData:
            return "The secret value is missing expected data."
        case .wrongSecretType:
            return "The decrypted secret is of an unexpected type."
        }
    }
}

extension Optional {
    /// Convienence method to `throw` if an optional type has a `nil` value.
    ///
    /// - Parameter error: The error to throw.
    /// - Returns: The unwrapped value.
    func unwrap(or error: @autoclosure () -> LocalizedError) throws -> Wrapped {
        switch self {
        case .some(let wrapped): return wrapped
        case .none: throw error()
        }
    }
}
