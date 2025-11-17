// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MGNetworkKit",
    platforms: [
        .iOS(.v16), .macOS(.v13)
    ],
    products: [
        .library(name: "MGNetworkKit", targets: ["MGNetworkKit"]),
        .library(name: "MGNetworkMacros", targets: ["MGNetworkMacros"]),
        .executable(name: "MGNetworkKitApp", targets: ["MGNetworkKitApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT")
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
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "Sources/MGNetworkMacrosImplementation"
        ),
        .executableTarget(
            name: "MGNetworkKitApp",
            dependencies: ["MGNetworkKit", "MGNetworkMacros", "Alamofire"],
            path: "Examples/NetworkKitDemo"
        ),
//        .testTarget(
//            name: "MGNetworkKitTests",
//            dependencies: ["MGNetworkKit"],
//            path: "Tests/MGNetworkKitTests"
//        )
    ]
)
