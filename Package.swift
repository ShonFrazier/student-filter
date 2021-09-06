// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tutoring-reminder",
    dependencies: [
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .revision("swift-5.4.2-RELEASE")),
    ],
    targets: [
        .target(
            name: "tutoring-reminder",
            dependencies: ["SwiftSyntax"]),
        .testTarget(
            name: "tutoring-reminderTests",
            dependencies: ["tutoring-reminder"]),
    ]
)
