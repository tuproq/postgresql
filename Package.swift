// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "tuproq-postgresql",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
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
        .executableTarget(name: "PostgreSQLExample", dependencies: [
            .target(name: "PostgreSQL")
        ]),
        .testTarget(name: "PostgreSQLTests", dependencies: [
            .target(name: "PostgreSQL")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
