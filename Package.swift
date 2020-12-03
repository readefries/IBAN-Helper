// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "IBAN-Helper",
    products: [
        .library(
            name: "RFIBANHelper",
            targets: ["RFIBANHelper"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RFIBANHelper",
            dependencies: [],
            path: "RFIBAN-Helper",
            sources: [
                "Classes/"
            ],
            resources: [
                .process("Assets/")
            ]),
        .testTarget(
            name: "RFIBANHelperTests",
            dependencies: ["RFIBANHelper"],
            path: "Example/Tests",
            exclude: [
                "Info.plist"
            ]),
    ]
)
