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

struct ImageSourceBase: View {
	var properties: ImageProperties
	
	var body: some View {
		Rectangle()
			.fill(Color.clear)
			.frame(idealWidth: properties.imageSize?.width, idealHeight: properties.imageSize?.height)
	}
}

struct StaticImageSourceView: View {
	@ObjectBinding var imageSource: ImageSource
	var animationFrame: Int = 0
	var label: Text
	
	var body: some View {
		let image = self.imageSource.cgImage(at: animationFrame)
		let properties = imageSource.properties(at: animationFrame)
		
		return ImageSourceBase(properties: properties)
			.overlay(
				(image.map { Image($0, scale: 1, label: self.label) } ?? Image(systemName: "slash.circle.fill"))
					.resizable()
					// hide the slash circle placeholder
					.opacity(image == nil ? 0 : 1)
					// adjust based on exif orientation
					.rotationEffect(properties.rotateZ)
					.scaleEffect(x: properties.scaleX,
					             y: properties.scaleY,
					             anchor: .center)
			)
	}
}
