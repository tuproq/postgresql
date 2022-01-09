// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "tuproq-postgresql",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "PostgreSQL", targets: ["PostgreSQL"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "PostgreSQL", dependencies: [
            .product(name: "Logging", package: "swift-log"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl")
        ]),
        .testTarget(name: "PostgreSQLTests", dependencies: [
            .target(name: "PostgreSQL")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
