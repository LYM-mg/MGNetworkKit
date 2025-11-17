// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MGNetworkKit",
    platforms: [
        .iOS(.v15), .macOS(.v13)
    ],
    products: [
        .library(name: "MGNetworkKit", targets: ["MGNetworkKit"]),
        .library(name: "MGNetworkMacros", targets: ["MGNetworkMacros"]),
        .executable(name: "MGNetworkKitApp", targets: ["MGNetworkKitApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
        
        // 🚨 修复点：为 swift-syntax 显式命名
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.3"),
    ],
    targets: [
        .target(
            name: "MGNetworkKit",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "Sources/MGNetworkKit"
        ),
        .target(
            name: "MGNetworkMacros",
            dependencies: ["MGNetworkMacrosImplementation"],
            path: "Sources/MGNetworkMacros"
        ),
        .macro(
            name: "MGNetworkMacrosImplementation",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
        ),
        .executableTarget(
            name: "MGNetworkKitApp",
            dependencies: ["MGNetworkKit", "MGNetworkMacros", .product(name: "Alamofire", package: "Alamofire")],
            path: "Examples/NetworkKitDemo"
        ),
    ]
)
