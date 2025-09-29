// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OxideModules",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15) // Added for compatibility
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Root",
            targets: ["Root"]
        ),
        .library(
            name: "Home",
            targets: ["Home"]
        ),
        .library(
            name: "Gallery",
            targets: ["Gallery"]
        ),
        .library(
            name: "Settings",
            targets: ["Settings"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "main"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppCore",
            dependencies: []
        ),
        .target(
            name: "Root",
            dependencies: [
                "Home",
                "AppCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Lottie", package: "lottie-spm")
            ]
        ),
        .testTarget(
            name: "RootTests",
            dependencies: ["Root"]
        ),
        .target(
            name: "Home",
            dependencies: [
                "Gallery",
                "Settings",
                "AppCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "HomeTests",
            dependencies: ["Home"]
        ),
        .target(
            name: "Gallery",
            dependencies: [
                "AppCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "GalleryTests",
            dependencies: ["Gallery"]
        ),
        .target(
            name: "Settings",
            dependencies: [
                "AppCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]
        ),
    ]
)
