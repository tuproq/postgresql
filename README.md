# PostgreSQL client
[![Swift](https://img.shields.io/badge/swift-5.1-brightgreen.svg)](https://swift.org/download/#releases) [![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/tuproq/postgresql/blob/master/LICENSE/) [![Actions Status](https://github.com/tuproq/postgresql/workflows/development/badge.svg)](https://github.com/tuproq/postgresql/actions) [![Contributing](https://img.shields.io/badge/contributing-guide-brightgreen.svg)](https://github.com/tuproq/postgresql/blob/master/CONTRIBUTING.md) [![Twitter](https://img.shields.io/badge/twitter-tuproqdev-brightgreen.svg)](https://twitter.com/tuproqdev)

### Swift
Download and install [Swift](https://swift.org/download)

### Swift Package
#### Shell
```shell
mkdir MyApp
cd MyApp
swift package init --type executable // Creates an executable app named "MyApp"
```

#### Package.swift
```swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/tuproq/postgresql.git", .branch("master"))
    ],
    targets: [
        .target(name: "MyApp", dependencies: ["PostgreSQL"]),
        .testTarget(name: "MyAppTests", dependencies: ["MyApp"])
    ]
)
```
