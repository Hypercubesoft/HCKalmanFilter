import PackageDescription

let package = Package(
    name: "HCKalmanFilter",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "HCKalmanFilter",
            targets: ["HCKalmanFilter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Jounce/Surge", from: "2.3.0"),
    ],
    targets: [
        .target(
            name: "HCKalmanFilter",
            dependencies: []
        )
    ]
)