// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Webug",
    products: [
        .executable(name: "webug", targets: ["Webug"]),
        .library(name: "WebugCore", targets: ["WebugCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.3.1"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0-alpha.3"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha.2.1"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-alpha.3"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-alpha.3"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0-alpha.1")
    ],
    targets: [
        .target(
            name: "Webug",
            dependencies: [
                "Vapor",
                "WebugCore"
            ]
        ),
        .target(
            name: "WebugCore",
            dependencies: [
                "Vapor",
                "Fluent",
                "FluentPostgresDriver",
                "FluentSQLiteDriver",
                "Redis"
            ]
        )
    ]
)


