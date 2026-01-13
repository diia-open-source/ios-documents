// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiiaDocuments",
    defaultLocalization: "uk",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DiiaDocuments",
            targets: ["DiiaDocuments"]),
        .library(
            name: "DiiaDocumentsCore",
            targets: ["DiiaDocumentsCore"]),
        .library(
            name: "DiiaDocumentsCommonTypes",
            targets: ["DiiaDocumentsCommonTypes"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/diia-open-source/ios-mvpmodule.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/diia-open-source/ios-network.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/diia-open-source/ios-commontypes.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/diia-open-source/ios-commonservices.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/diia-open-source/ios-uicomponents.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.3.0"),
        .package(url: "https://github.com/DeclarativeHub/ReactiveKit.git", .upToNextMinor(from: "3.16.2")),
        .package(url: "https://github.com/airbnb/lottie-spm.git", exact: Version(4, 6, 0)),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DiiaDocumentsCommonTypes",
            dependencies: [
                "ReactiveKit",
                .product(name: "DiiaCommonTypes", package: "ios-commontypes"),
                .product(name: "DiiaNetwork", package: "ios-network"),
                .product(name: "DiiaUIComponents", package: "ios-uicomponents"),
                .product(name: "Lottie", package: "lottie-spm"),
            ],
            path: "Sources/DocumentsCommonTypes",
            resources: [.process("Resources/Animations")]
        ),
        .target(
            name: "DiiaDocumentsCore",
            dependencies: [
                .product(name: "DiiaMVPModule", package: "ios-mvpmodule"),
                .product(name: "DiiaNetwork", package: "ios-network"),
                .product(name: "DiiaCommonTypes", package: "ios-commontypes"),
                .product(name: "DiiaUIComponents", package: "ios-uicomponents"),
                .product(name: "DiiaCommonServices", package: "ios-commonservices"),
                .product(name: "Lottie", package: "lottie-spm"),
                "SwiftyJSON",
                "DiiaDocumentsCommonTypes",
            ],
            path: "Sources/DocumentsCore",
            resources: [.process("Resources/Animations")]
        ),
        .target(
            name: "DiiaDocuments",
            dependencies: [
                .product(name: "DiiaCommonTypes", package: "ios-commontypes"),
                .product(name: "DiiaUIComponents", package: "ios-uicomponents"),
                "DiiaDocumentsCommonTypes",
                "DiiaDocumentsCore"
            ],
            path: "Sources/Documents"
        ),
        .testTarget(
            name: "DocumentsTests",
            dependencies: ["DiiaDocuments", "DiiaDocumentsCommonTypes"]),
        .testTarget(
            name: "DiiaDocumentsCommonTypesTests",
            dependencies: ["DiiaDocumentsCommonTypes"]),
        .testTarget(
            name: "DocumentsCoreTests",
            dependencies: ["DiiaDocumentsCore","DiiaDocumentsCommonTypes"]),
    ]
)
