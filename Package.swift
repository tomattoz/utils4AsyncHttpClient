// swift-tools-version:5.9.2

import PackageDescription

let package = Package(
    name: "AsyncHttpClientUtils9",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v10_15)],
    products: [
        .library(name: "AsyncHttpClientUtils9", targets: ["AsyncHttpClientUtils9"]),
    ],
    dependencies: [
        .package(path: "../utils"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.22.0"),
    ],
    targets: [
        .target(name: "AsyncHttpClientUtils9",
                dependencies: [
                    .product(name: "Utils9", package: "utils"),
                    .product(name: "AsyncHTTPClient", package: "async-http-client"),
                ],
                path: "Sources")
    ]
)
