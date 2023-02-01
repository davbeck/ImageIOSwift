// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "ImageIOSwift",
	platforms: [
		.macOS(.v10_15), .iOS(.v13), .watchOS(.v6), .tvOS(.v13),
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
