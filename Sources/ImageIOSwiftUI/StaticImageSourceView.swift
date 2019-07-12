import ImageIOSwift
import SwiftUI

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
public struct ImageSourceBase: View {
	var properties: ImageProperties
	
	public var body: some View {
		Rectangle()
			.fill(Color.clear)
			.frame(idealWidth: properties.imageSize?.width, idealHeight: properties.imageSize?.height)
	}
}

/// Displays a single frame of an image source.
public struct StaticImageSourceView: View {
	@ObjectBinding public var imageSource: ImageSource
	public var animationFrame: Int = 0
	public var label: Text
	
	public init(imageSource: ImageSource, animationFrame: Int = 0, label: Text) {
		self.imageSource = imageSource
		self.animationFrame = animationFrame
		self.label = label
	}
	
	public var body: some View {
		let image = self.imageSource.cgImage(at: animationFrame)
		let properties = imageSource.properties(at: animationFrame)
		
		return ImageSourceBase(properties: properties)
			.overlay(
				image.map { Image($0, scale: 1, label: self.label)
					.resizable()
					// adjust based on exif orientation
					.rotationEffect(properties.rotateZ)
					.scaleEffect(x: properties.scaleX,
					             y: properties.scaleY,
					             anchor: .center)
				}
			)
	}
}
