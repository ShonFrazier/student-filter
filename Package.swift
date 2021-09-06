// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tutoring-reminder",
    dependencies: [
    ],
    targets: [
        .target(
            name: "tutoring-reminder",
            dependencies: []
        ),
        .testTarget(
            name: "tutoring-reminderTests",
            dependencies: ["tutoring-reminder"]),
    ]
)
