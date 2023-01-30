import ImageIOSwift
import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension ImageProperties {
	var rotateZ: Angle {
		switch self.exifOrientation {
		case 2:
			return .zero
		case 3:
			return .degrees(180)
		case 4:
			return .zero
		case 5:
			return .degrees(90)
		case 6:
			return .degrees(90)
		case 7:
			return .degrees(-90)
		case 8:
			return .degrees(-90)
		default: // 1
			return .zero
		}
	}

	var scaleX: CGFloat {
		switch self.exifOrientation {
		case 2:
			return -1
		case 3:
			return 1
		case 4:
			return 1
		case 5:
			return -imageSize!.width / imageSize!.height
		case 6:
			return imageSize!.width / imageSize!.height
		case 7:
			return -imageSize!.width / imageSize!.height
		case 8:
			return imageSize!.width / imageSize!.height
		default: // 1
			return 1
		}
	}

	var scaleY: CGFloat {
		switch self.exifOrientation {
		case 2:
			return 1
		case 3:
			return 1
		case 4:
			return -1
		case 5:
			return imageSize!.height / imageSize!.width
		case 6:
			return imageSize!.height / imageSize!.width
		case 7:
			return imageSize!.height / imageSize!.width
		case 8:
			return imageSize!.height / imageSize!.width
		default: // 1
			return 1
		}
	}
}

/// Provides the layout bounds of an image source.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ImageSourceBase: View {
	var properties: ImageProperties

	public var body: some View {
		Rectangle()
			.fill(Color.clear)
			.frame(idealWidth: properties.imageSize?.width, idealHeight: properties.imageSize?.height)
	}
}

/// Displays a single frame of an image source.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct StaticImageSourceView: View {
	public var image: CGImage?
	public var properties: ImageProperties
	public var label: Text

	public init(image: CGImage?, properties: ImageProperties, label: Text) {
		self.image = image
		self.properties = properties
		self.label = label
	}

	public var body: some View {
		ImageSourceBase(properties: properties)
			.overlay(
				image.map { Image($0, scale: 1, label: self.label)
					.resizable()
					.renderingMode(.original)
					// adjust based on exif orientation
					.rotationEffect(properties.rotateZ)
					.scaleEffect(x: properties.scaleX,
					             y: properties.scaleY,
					             anchor: .center)
				}
			)
	}
}
