// swift-tools-version: 5.9
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
        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "1.0.0")
    ],
    targets: [
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

let regularTargets: [Target] = [
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
    )
]

for target in regularTargets {
    target.swiftSettings = [.enableExperimentalFeature("StrictConcurrency")]
}

package.targets.append(contentsOf: regularTargets)
