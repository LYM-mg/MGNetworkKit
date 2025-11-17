// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "MGNetworkKit",
    platforms: [
        .iOS(.v15), .macOS(.v13)
    ],
    products: [
        .library(name: "MGNetworkKit", targets: ["MGNetworkKit"]),
//        .library(name: "MGNetworkMacros", targets: ["MGNetworkMacros"]),
        // 你可以不把宏实现模块作为 product 对外，如果仅供内部使用
//        .library(name: "MGNetworkMacrosImplementation", targets: ["MGNetworkMacrosImplementation"]),
        .executable(name: "MGNetworkKitApp", targets: ["MGNetworkKitApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ],
    targets: [
        .target(
            name: "MGNetworkKit",
            dependencies: [
                Target.Dependency.product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ],
            path: "Sources"
        ),
//        .target(
//            name: "MGNetworkMacros",
//            dependencies: ["MGNetworkMacrosImplementation"],
//            path: "Sources/MGNetworkMacros"
//        ),
//        .target(
//            name: "MGNetworkMacrosImplementation",
//            dependencies: [
//                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
//                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
//                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
//                .product(name: "SwiftSyntax", package: "swift-syntax")
//            ],
//            path: "Sources/MGNetworkMacrosImplementation"
//        ),
        .executableTarget(
            name: "MGNetworkKitApp",
            dependencies: ["MGNetworkKit", Target.Dependency.product(name: "Alamofire", package: "Alamofire")],
            path: "Examples/NetworkKitDemo"
        ),
//        .testTarget(
//            name: "MGNetworkKitTests",
//            dependencies: ["MGNetworkKit"],
//            path: "Tests/MGNetworkKitTests"
//        )
    ]
)
