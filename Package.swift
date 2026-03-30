// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "tuproq-postgresql",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "PostgreSQL", targets: ["PostgreSQL"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "PostgreSQL", dependencies: [
            .product(name: "Crypto", package: "swift-crypto"),
            .product(name: "Logging", package: "swift-log"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
            .product(name: "NIOFoundationCompat", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl")
        ]),
        .testTarget(name: "PostgreSQLTests", dependencies: [
            .target(name: "PostgreSQL")
        ])
    ]
)
