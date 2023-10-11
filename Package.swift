// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthblueSwiftSDK",
    defaultLocalization: "ja",   // - NEW
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AuthblueSwiftSDK",
            targets: ["AuthblueSwiftSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kenmaro3/TRETJapanNFCReader.git", from: "0.0.0"),
        .package(url: "https://github.com/filom/ASN1Decoder.git", from: "1.9.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
        .package(url: "https://github.com/apple/swift-asn1", from: "0.10.0"),
        .package(url: "https://github.com/globulus/swiftui-digital-signature", from: "0.1.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AuthblueSwiftSDK",
            dependencies: [
                .product(name: "TRETJapanNFCReader-MIFARE-IndividualNumber", package: "TRETJapanNFCReader"),      // (1)
                .product(name: "ASN1Decoder", package: "ASN1Decoder"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "SwiftUIDigitalSignature", package: "swiftui-digital-signature")
            ],
            resources: [.process("Resources")]),
        
        .testTarget(
            name: "AuthblueSwiftSDKTests",
            dependencies: ["AuthblueSwiftSDK"]),
    ]
)
