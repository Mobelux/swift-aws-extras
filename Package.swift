// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-aws-extras",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "EmailSender", targets: ["EmailSender"]),
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "Secrets", targets: ["Secrets"])
    ],
    dependencies: [
        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "0.19.0")
    ],
    targets: [
        .target(
            name: "EmailSender",
            dependencies: [
                .product(name: "AWSSES", package: "aws-sdk-swift")
            ]
        ),
        .target(
            name: "Persistence",
            dependencies: [
                .product(name: "AWSDynamoDB", package: "aws-sdk-swift")
            ]
        ),
        .target(
            name: "Secrets",
            dependencies: [
                .product(name: "AWSSecretsManager", package: "aws-sdk-swift")
            ]
        ),
        // MARK: - Tests
        .testTarget(
            name: "EmailSenderTests",
            dependencies: ["EmailSender"]
        ),
        .testTarget(
            name: "PersistenceTests",
            dependencies: ["Persistence"]
        ),
        .testTarget(
            name: "SecretsTests",
            dependencies: ["Secrets"]
        )
    ]
)
