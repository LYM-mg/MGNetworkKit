// swift-tools-version:5.09
import PackageDescription

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
        .target(
            name: "MGNetworkMacrosImplementation",
            path: "Sources/MGNetworkMacrosImplementation"
        ),
        .executableTarget(
            name: "MGNetworkKitApp",
            dependencies: ["MGNetworkKit", "MGNetworkMacros", .product(name: "Alamofire", package: "Alamofire")],
            path: "Examples/NetworkKitDemo"
        ),
    ]
)
