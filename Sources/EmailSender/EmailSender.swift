//
//  EmailSender.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

@preconcurrency import AWSSES
import Foundation

/// A type that sends emails.
public struct EmailSender: Sendable {
    /// A closure returning a message ID after sending an email.
    public var send: @Sendable (Recipients, Sender, Subject, Body) async throws -> MessageID?

    /// Creates an instance.
    ///
    /// - Parameter send: A closure that sends an email.
    public init(
        send: @escaping @Sendable (Recipients, Sender, Subject, Body) async throws -> MessageID?
    ) {
        self.send = send
    }
}

public extension EmailSender {
    /// Returns a live implementation.
    ///
    /// - Parameter sesClient: The `SESClient` used to send emails.
    /// - Returns: A live implementation of an email sender.
    static func live(sesClient: SESClient) -> Self {
        .init(send: { recipents, sender, subject, body in
            let email = SendEmailInput(
                destination: SESClientTypes.Destination(
                    toAddresses: recipents
                ),
                message: SESClientTypes.Message(
                    body: SESClientTypes.Body(body),
                    subject: SESClientTypes.Content(data: subject)
                ),
                replyToAddresses: nil,
                returnPath: nil,
                source: sender
            )

            return try await sesClient.sendEmail(input: email).messageId
        })
    }
}

/// A type that creates ``EmailSender`` instances.
public struct EmailSenderFactory {
    /// A closure that creates and returns an ``EmailSender`` instance.
    public var make: @Sendable () async throws -> EmailSender

    /// Creates an instance.
    ///
    /// - Parameter make: A closure returning an ``EmailSender`` instance.
    public init(make: @escaping @Sendable () async throws -> EmailSender) {
        self.make = make
    }
}

public extension EmailSenderFactory {
    /// A live implementation.
    static var live: Self {
        .init(make: {
            let sesClient = try await SESClient()
            return EmailSender.live(sesClient: sesClient)
        })
    }
}
