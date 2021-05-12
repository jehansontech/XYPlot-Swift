// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "XYPlotForSwift",
    platforms: [
        .macOS(.v11), .iOS(.v14)
    ],
    products: [
        .library(
            name: "XYPlotForSwift",
            targets: ["XYPlotForSwift"])
    ],
    dependencies: [
        .package(url: "git@github.com:jehansontech/Wacoma.git", .branch("dev"))
    ],
    targets: [
        .target(
            name: "XYPlotForSwift",
            dependencies: [.product(name: "WacomaUI", package: "Wacoma")]),
	.testTarget(
	    name: "XYPlotForSwiftTests",
            dependencies: ["XYPlotForSwift"])
    ]
)
