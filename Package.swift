// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftUI-PhotoPicker",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "PhotoPicker",
            targets: ["PhotoPicker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PhotoPicker",
            dependencies: []),
    ]
)
