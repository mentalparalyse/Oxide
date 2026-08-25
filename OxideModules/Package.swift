// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let packageDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
let installedEffectsPath = packageDirectory
    .appendingPathComponent("../Oxide-Effects")
    .standardizedFileURL
    .path
let legacyEffectsPath = packageDirectory
    .appendingPathComponent("../../Oxide-Effects")
    .standardizedFileURL
    .path
let privateEffectsPath: String? = {
    guard ProcessInfo.processInfo.environment["OXIDE_DISABLE_PRIVATE_EFFECTS"] != "1" else {
        return nil
    }

    for path in [installedEffectsPath, legacyEffectsPath] where
        FileManager.default.fileExists(atPath: "\(path)/Package.swift")
    {
        return path
    }
    return nil
}()

let privateDependencies: [Package.Dependency] = privateEffectsPath.map {
    [.package(path: $0)]
} ?? []

let imageProcessorDependencies: [Target.Dependency] = privateEffectsPath.map { _ in
    [.product(name: "OxideEffects", package: "Oxide-Effects")]
} ?? []

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
            name: "Editor",
            targets: ["Editor"]
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
    dependencies: privateDependencies,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppCore",
            dependencies: [],
        ),
        .target(
            name: "UIComponents",
            dependencies: [],
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
                "UIComponents",
            ]
        ),
        .testTarget(
            name: "HomeTests",
            dependencies: ["Home"]
        ),
        .target(
            name: "Editor",
            dependencies: [
                "AppCore",
                "ImageProcessor",
                "UIComponents"
            ]
        ),
        .testTarget(
            name: "EditorTests",
            dependencies: [
                "Editor",
                "ImageProcessor"
            ]
        ),
        .target(
            name: "Gallery",
            dependencies: [
                "Editor",
                "AppCore",
                "ImageProcessor",
                "UIComponents"
            ]
        ),
        .testTarget(
            name: "GalleryTests",
            dependencies: [
                "Gallery",
                "Editor",
                "ImageProcessor"
            ]
        ),
        .target(
            name: "Settings",
            dependencies: [
                "AppCore",
                "UIComponents",
            ]
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]
        ),
        .target(
            name: "ImageProcessor",
            dependencies: imageProcessorDependencies,
            resources: [
                .process("LUTs")
            ]
        ),
        .testTarget(
            name: "ImageProcessorTests",
            dependencies: ["ImageProcessor"]
        ),
        .target(
            name: "Onboarding",
            dependencies: [
                "AppCore",
                "UIComponents",
            ]
        ),
        .target(
            name: "Splash",
            dependencies: [
                "AppCore",
                "UIComponents"
            ]
        ),
    ]
)
