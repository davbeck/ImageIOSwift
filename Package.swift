// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "ImageIOSwift",
	platforms: [
		.macOS(.v10_10), .iOS(.v9), .watchOS(.v2), .tvOS(.v9),
	],
	products: [
		.library(
			name: "ImageIOSwift",
			targets: ["ImageIOSwift"]
		),
		.library(
			name: "ImageIOUIKit",
			targets: ["ImageIOUIKit"]
		),
		.library(
			name: "ImageIOSwiftUI",
			targets: ["ImageIOSwiftUI"]
		),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "ImageIOSwift",
			dependencies: []
		),
		.target(
			name: "ImageIOUIKit",
			dependencies: ["ImageIOSwift"]
		),
		.target(
			name: "ImageIOSwiftUI",
			dependencies: ["ImageIOSwift"]
		),
		.testTarget(
			name: "ImageIOSwiftTests",
			dependencies: ["ImageIOSwift"]
		),
	]
)
