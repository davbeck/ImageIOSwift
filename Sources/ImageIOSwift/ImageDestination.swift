import Foundation
import ImageIO
import Combine
import UniformTypeIdentifiers

public class ImageDestination {
	/// The underlying image destination
	public let cgImageDestination: CGImageDestination

	public init(_ cgImageDestination: CGImageDestination) {
		self.cgImageDestination = cgImageDestination
	}

	public struct ImageOptions {
		public var lossyCompressionQuality: Double?

		public init(lossyCompressionQuality: Double? = nil) {
			self.lossyCompressionQuality = lossyCompressionQuality
		}

		public var rawValue: CFDictionary {
			var options: [CFString: Any] = [:]

			if let lossyCompressionQuality {
				options[kCGImageDestinationLossyCompressionQuality] = lossyCompressionQuality
			}

			return options as CFDictionary
		}
	}

	public func add(_ image: CGImage, options: ImageOptions = ImageOptions()) {
		CGImageDestinationAddImage(
			cgImageDestination,
			image,
			options.rawValue
		)
	}

	public func add(from source: ImageSource, at index: Int, options: ImageOptions = ImageOptions()) {
		CGImageDestinationAddImageFromSource(
			cgImageDestination,
			source.cgImageSource,
			index,
			options.rawValue
		)
	}
}

public final class URLImageDestination: ImageDestination {
	@available(iOS 14.0, *)
	public convenience init?(url: URL, type: UTType, count: Int = 1) {
		self.init(url: url, typeIdentifier: type.identifier, count: count)
	}

	public init?(url: URL, typeIdentifier: String, count: Int = 1) {
		guard let destination = CGImageDestinationCreateWithURL(
			url as CFURL,
			typeIdentifier as CFString,
			count,
			nil
		) else { return nil }

		super.init(destination)
	}

	public func finalize() -> Bool {
		CGImageDestinationFinalize(cgImageDestination)
	}
}

public final class DataImageDestination: ImageDestination {
	private let mutableData = NSMutableData()

	@available(iOS 14.0, *)
	public convenience init?(type: UTType, count: Int = 1) {
		self.init(typeIdentifier: type.identifier, count: count)
	}

	public init?(typeIdentifier: String, count: Int = 1) {
		guard let destination = CGImageDestinationCreateWithData(
			mutableData,
			typeIdentifier as CFString,
			count,
			nil
		) else { return nil }

		super.init(destination)
	}

	public func finalize() -> Data? {
		guard CGImageDestinationFinalize(cgImageDestination) else { return nil }

		return mutableData as Data
	}
}
