// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PipelineBasicLogging",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PipelineBasicLogging",
            targets: ["PipelineBasicLogging"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftxml/PipelineLoggingBinding.git", from: "1.0.7"),
        .package(url: "https://github.com/swiftxml/BasicLogging.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PipelineBasicLogging",
            dependencies: [
                "PipelineLoggingBinding",
                "BasicLogging",
            ]
        ),
        .testTarget(
            name: "PipelineBasicLoggingTests",
            dependencies: ["PipelineBasicLogging"]
        ),
    ]
)
