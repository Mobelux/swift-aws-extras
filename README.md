# AWS Extras

Swifty helpers for working with the Swift [AWS SDK](https://github.com/awslabs/aws-sdk-swift).

## 📱 Requirements

Swift 5.9 toolchain with Swift Package Manager.

## 🖥 Installation

AWS Extras is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, add it as a dependency within your `Package.swift` manifest:

```swift
dependencies: [
    .package(url: "https://github.com/Mobelux/swift-aws-extras.git", from: "0.1.0")
]
```

Then, add the relevant product to any targets that need access to the library:

```swift
.product(name: "<product>", package: "swift-aws-extras"),
```

Where `<product>` is one of the following:

- `EmailSender`
- `Persistence`
- `Secrets`

## ⚙️ Usage

### 📧 EmailSender

Initialize an `EmailSender`:

```swift
let sender = try await EmailSenderFactory.live().make()
```

To send an email with a plain text body:

```swift
let messageID = try await sender.send(
    ["recipient@mail.com"],
    "sender@mail.com",
    "Subject",
    .text("Plain text email content")
)
```

To send an email with both plain text and HTML:

```swift
let messageID = try await sender.send(
    ["recipient@mail.com"],
    "sender@mail.com",
    "Subject",
    .combined("Plain text email content", "<!doctype html>\n<html>...</html>")
)
```

### 🗄️ Persistence

Add `AttributeValueConvertible` conformance to model types:

```swift
struct MyModel: Codable {
    let name: String
    let value: Int
}

extension MyModel: AttributeValueConvertible {
    var attributes: [String: AttributeValue] {
        [
            CodingKeys.name: .s(name),
            CodingKeys.value: .n(String(value))
        ].attributeValues()
    }
}
```

Initialize `Persistence`:

```swift
let persistence = try await PersistenceFactory.make(
    "us-east-1",
    "TableName)
```

Persist a model instance:

```swift
let model = MyModel(name: "foo", value: 42)
try await persistence.put(model)
```

### 🗝️ Secrets

Initialize `Secrets` with a region:

```swift
let secrets = Secrets.live(region: "us-east-1")
```

Retrieve a secret string by its id:

```swift
let secret = try await secrets.string("my-secret-id")
```

Retrieve secret data by its id:

```swift
let secret = try await secrets.data("my-secret-id")
```

Retrieve multiple secrets:

```swift
let secrets = try await secrets.batch([
    "my-secret-id",
    "my-other-secret-id"
])
```
