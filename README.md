# PostgreSQL client
[![Swift](https://img.shields.io/badge/swift-5.1-brightgreen.svg)](https://swift.org/download/#releases) [![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/chaqmoq/postgresql/blob/master/LICENSE/) [![Actions Status](https://github.com/chaqmoq/postgresql/workflows/development/badge.svg)](https://github.com/chaqmoq/postgresql/actions) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/e50619f48958499da0851563c9433df2)](https://www.codacy.com/gh/chaqmoq/postgresql?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=chaqmoq/postgresql&amp;utm_campaign=Badge_Grade) [![Contributing](https://img.shields.io/badge/contributing-guide-brightgreen.svg)](https://github.com/chaqmoq/postgresql/blob/master/CONTRIBUTING.md) [![Twitter](https://img.shields.io/badge/twitter-chaqmoqdev-brightgreen.svg)](https://twitter.com/chaqmoqdev)

## Installation

### Package.swift
```swift
let package = Package(
    // ...
    dependencies: [
        // Other packages...
        .package(url: "https://github.com/chaqmoq/postgresql.git", .branch("master"))
    ],
    targets: [
        // Other targets...
        .target(name: "...", dependencies: ["PostgreSQL"])
    ]
)
```
