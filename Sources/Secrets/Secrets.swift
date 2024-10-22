//
//  Secrets.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/22/23.
//

@preconcurrency import AWSSecretsManager
import Foundation

/// A secret stored by AWS Secrets Manager.
public struct Secret: Equatable, Sendable {

    /// A secret stored by AWS Secrets Manager.
    public enum Value: Equatable, Sendable {
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
    public var arn: String

    /// The friendly name of the secret.
    public var name: String

    /// The decrypted secret value.
    public var value: Value

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
    /// Creates a new instance.
    ///
    /// - Parameter secretValue: A secret value.
    init<V: SecretValue>(_ secretValue: V) throws {
        guard let arn = secretValue.arn, let name = secretValue.name else {
            throw SecretsError.missingData
        }

        self.arn = arn
        self.name = name
        if let string = secretValue.secretString {
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

/// A type that retrieves secrets.
public struct Secrets: Sendable {
    /// The ARN or name of the secret to retrieve.
    public typealias ID = String

    /// A closure returning the secret string for the given identifier.
    public var string: @Sendable (ID) async throws -> String

    /// A closure returning the secret data for the given identifier.
    public var data: @Sendable (ID) async throws -> Data

    /// A closure returning secrets for the given identifiers.
    public var batch: @Sendable ([ID]) async throws -> [Secret]?

    public init(
        string: @escaping @Sendable (Secrets.ID) async throws -> String,
        data: @escaping @Sendable (Secrets.ID) async throws -> Data,
        batch: @escaping @Sendable ([Secrets.ID]) async throws -> [Secret]?
    ) {
        self.string = string
        self.data = data
        self.batch = batch
    }
}

public extension Secrets {
    /// Returns a live implementation.
    ///
    /// - Parameter region: The AWS region of the secrets manager.
    /// - Returns: A live instance.
    static func live(region: String) throws -> Self {
        let client = try SecretsManagerClient(region: region)
        return Secrets(
            string: { id in
                try await client.getSecretValue(input: GetSecretValueInput(secretId: id))
                    .secretString
                    .unwrap(or: SecretsError.wrongSecretType)
            },
            data: { id in
                try await client.getSecretValue(input: GetSecretValueInput(secretId: id))
                    .secretBinary
                    .unwrap(or: SecretsError.wrongSecretType)
            },
            batch: { secretIDs in
                let batchInput = BatchGetSecretValueInput(secretIdList: secretIDs)
                return try await client.batchGetSecretValue(input: batchInput)
                    .secretValues?
                    .map { try Secret($0) }
            })
    }
}

/// A type that creates ``Secrets`` instances.
public struct SecretsFactory: Sendable {
    /// The region where the secrets manager is located.
    public typealias Region = String

    /// A closure that creates and returns a ``Secrets`` instance.
    public var make: @Sendable (Region) throws -> Secrets

    /// Creates an instance.
    ///
    /// - Parameter make: A closure returning a ``Secrets`` instance.
    public init(
        make: @escaping @Sendable (SecretsFactory.Region) throws -> Secrets
    ) {
        self.make = make
    }
}

public extension SecretsFactory {
    /// Returns a live implementation.
    static func live() -> Self {
        .init(make: { try Secrets.live(region: $0 ) })
    }
}
