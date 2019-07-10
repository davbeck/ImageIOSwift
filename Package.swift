import PackageDescription

let package = Package(
    name: "ImageIOSwift",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ImageIOSwift",
            targets: ["ImageIOSwift"]
        ),
        .library(
            name: "ImageIOUIKit",
            targets: ["ImageIOUIKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ImageIOSwift",
            dependencies: []
        ),
        .target(
            name: "ImageIOUIKit",
            dependencies: ["ImageIOSwift"]
        ),
        .testTarget(
            name: "ImageIOSwiftTests",
            dependencies: ["ImageIOSwift"]
        ),
    ]
)
