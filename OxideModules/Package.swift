// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OxideModules",
    platforms: [
        .iOS(.v16)
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
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]
        ),
        .library(
            name: "Splash",
            targets: ["Splash"]
        ),
        .library(
            name: "ImageProcessor",
            targets: ["ImageProcessor"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppCore",
            dependencies: [],
//            resources: [
//                .process("Resources")
//            ]
        ),
        .target(
            name: "Root",
            dependencies: [
                "Home",
                "AppCore",
                "Splash",
                "Onboarding",
                "ImageProcessor"
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
            ]
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]
        ),
        .target(
            name: "ImageProcessor",
            dependencies: [],
            resources: [.process("Shaders")]
        ),
        .testTarget(
            name: "ImageProcessorTests",
            dependencies: ["ImageProcessor"]
        ),
        .target(
            name: "Onboarding",
            dependencies: [
                "AppCore"
            ]
        ),
        .target(
            name: "Splash",
            dependencies: [
                "AppCore",
                .product(name: "Lottie", package: "lottie-spm")
            ]
        ),
    ]
)
