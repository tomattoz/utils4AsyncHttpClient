// swift-tools-version:5.9.2

import PackageDescription

let package = Package(
    name: "Utils9AsyncHttpClient",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v10_15)],
    products: [
        .library(name: "Utils9AsyncHttpClient", targets: ["Utils9AsyncHttpClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.22.0"),
        .package(url: "https://github.com/tomattoz/utils", branch: "master"),
        .package(url: "https://github.com/tomattoz/utils4AdapterAI", branch: "master"),
    ],
    targets: [
        .target(name: "Utils9AsyncHttpClient",
                dependencies: [
                    .product(name: "Utils9", package: "utils"),
                    .product(name: "Utils9AIAdapter", package: "utils4AdapterAI"),
                    .product(name: "AsyncHTTPClient", package: "async-http-client"),
                ],
                path: "Sources")
    ]
)
