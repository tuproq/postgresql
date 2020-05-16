// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "chaqmoq-postgresql",
    products: [
        .library(name: "PostgreSQL", targets: ["PostgreSQL"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.17.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.7.2")
    ],
    targets: [
        .target(name: "PostgreSQL", dependencies: ["Logging", "NIO", "NIOSSL"]),
        .testTarget(name: "PostgreSQLTests", dependencies: ["PostgreSQL"])
    ]
)
