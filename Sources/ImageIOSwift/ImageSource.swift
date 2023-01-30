import Foundation
import ImageIO

/// An interface to an image file including metadata
///
/// You can think of `CG/NS/UIImage` as a single frame of pixels. `ImageSource` sits a level below that, providing access to almost anything an image *file* provides, including metadata and multiple representations. For instance, animated images have multiple image frames as well as timing metadata.
public class ImageSource {
	/// The underlying image source
	public let cgImageSource: CGImageSource

	public struct CreateOptions {
		public var typeIdentifierHint: String?

		public init(typeIdentifierHint: String? = nil) {
			self.typeIdentifierHint = typeIdentifierHint
		}

		public var rawValue: CFDictionary {
			var options: [CFString: Any] = [:]
			if let typeIdentifierHint = typeIdentifierHint {
				options[kCGImageSourceTypeIdentifierHint] = typeIdentifierHint
			}

			return options as CFDictionary
		}
	}

	public init(_ cgImageSource: CGImageSource) {
		self.cgImageSource = cgImageSource
	}

	/// Create an image source from a URL
	///
	/// While you can pass an http url to this method, it is recommended that you download files seperately using `URLSession`, which will load asynchronous. For best results, download to a file on disk and then call this method with that file url.
	///
	/// - Parameter url: The url to load the image file from.
	/// - Parameter options: Options to use for the created image source.
	public convenience init?(url: URL, options: CreateOptions? = nil) {
		guard let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, options?.rawValue) else { return nil }

		self.init(cgImageSource)
	}

	/// Create an image source from data in memory
	///
	/// Unlike `incremental(options:)`, this assumes the data represents the complete file from creation.
	///
	/// - Parameter data: The data representation of the image file.
	/// - Parameter options: Options to use for the created image source.
	public convenience init?(data: Data, options: CreateOptions? = nil) {
		guard let cgImageSource = CGImageSourceCreateWithData(data as CFData, options?.rawValue) else { return nil }

		self.init(cgImageSource)
	}

	// MARK: - Incremental

	/// Create an image source to load incrementally
	///
	/// If you are loading image data progressively (for instance as it downloads from the internet), you can use this to load the image data as it is recieved. Different file formats will behave differently using this method, but generally as much of the image as possible will be available as it loads. JPEG for instance will load individual lines as they become available, and if the file was encoded progressively, it will even display a full low resolution image before the rest of the detail is loaded. Animated images will load each frame as they become available.
	///
	/// - SeeAlso: `update(_:isFinal:)`
	/// - SeeAlso: `didUpdateData`
	///
	/// - Parameter options: Options to use for the created image source.
	/// - Returns: A new image source ready to be loaded.
	public static func incremental(options: CreateOptions? = nil) -> ImageSource {
		let cgImageSource = CGImageSourceCreateIncremental(options?.rawValue)

		return ImageSource(cgImageSource)
	}

	/// A notification that is fired when incremental is loaded
	///
	/// When an image source is being loaded incrementally, this is fired each time more data is added to the file. Use this to check if there is more image data available to display.
	///
	/// - Note: This will not work with updates that are applied directly to the underlying `CGImageSource`.
	public static let didUpdateData = Notification.Name(rawValue: "ImageIOSwift.ImageSource.didUpdateData")

	/// Notifies that an incremental image source has completely loaded.
	///
	/// - Note: This will not work with updates that are applied directly to the underlying `CGImageSource`.
	public static let didFinalizeData = Notification.Name(rawValue: "ImageIOSwift.ImageSource.didFinalizeData")

	/// Update an incremental image source with more data
	///
	/// When more data is available for an image, call this with *all of the available data so far*.
	///
	/// - Parameters:
	///   - data: All data available at this time.
	///   - isFinal: Set this to true when the file has been completely loaded.
	public func update(_ data: Data, isFinal: Bool) {
		CGImageSourceUpdateData(self.cgImageSource, data as CFData, isFinal)

		NotificationCenter.default.post(name: ImageSource.didUpdateData, object: self)
		if isFinal {
			NotificationCenter.default.post(name: ImageSource.didFinalizeData, object: self)
		}
	}

	// MARK: - Image Generation

	public struct ImageOptions {
		/// Whether the image should be returned as an image that uses floating-point values, if supported by the file format.
		///
		/// CGImage objects that use extended-range floating-point values may require additional processing to render in a pleasing manner. The default value is false.
		public var shouldAllowFloat: Bool = false

		/// Whether the image should be cached in a decoded form.
		///
		/// The default value is true.
		public var shouldCache: Bool = true

		/// Specifies whether image decoding and caching should happen at image creation time.
		///
		/// The default value is false (image decoding will happen at rendering time).
		public var shouldDecodeImmediately: Bool = false

		/// Whether the thumbnail should be rotated and scaled according to the orientation and pixel aspect ratio of the full image.
		///
		/// The default value is false.
		public var createThumbnailWithTransform: Bool = false

		/// Specifies when a thumbnail should be created.
		///
		/// Some images contain pre-rendered thumbnails that can be returned. Alternatively, a thumbnail can be generated when it's requested.
		public enum CreateThumbnailBehavior {
			/// Only use pre-rendered thumbnails from the original file.
			///
			/// This is the default.
			case never
			/// Automatically created for an image if a thumbnail isn't present in the image source file.
			///
			/// The thumbnail is created from the full image, subject to the limit specified by `thumbnailMaxPixelSize`. If a maximum pixel size isn't specified, then the thumbnail is the size of the full image, which in most cases is not desirable. The default value is false.
			case ifAbsent
			/// Create a thumbnail from the full image even if a thumbnail is present in the image source file.
			///
			/// The thumbnail is created from the full image, subject to the limit specified by `thumbnailMaxPixelSize`. If a maximum pixel size isn't specified, then the thumbnail is the size of the full image, which probably isn't what you want.
			case always
		}

		/// Specifies when a thumbnail should be created.
		///
		/// Some images contain pre-rendered thumbnails that can be returned. Alternatively, a thumbnail can be generated when it's requested.
		public var createThumbnailBehavior: CreateThumbnailBehavior = .never

		/// The maximum width and height in pixels of a thumbnail.
		///
		/// If this key is not specified, the width and height of a thumbnail is not limited and thumbnails may be as big as the image itself.
		public var thumbnailMaxPixelSize: CGFloat?

		public init(shouldAllowFloat: Bool = false, shouldCache: Bool = true, shouldDecodeImmediately: Bool = false, createThumbnailBehavior: CreateThumbnailBehavior = .never, thumbnailMaxPixelSize: CGFloat? = nil) {
			self.shouldAllowFloat = shouldAllowFloat
			self.shouldCache = shouldCache
			self.shouldDecodeImmediately = shouldDecodeImmediately
			self.createThumbnailBehavior = createThumbnailBehavior
			self.thumbnailMaxPixelSize = thumbnailMaxPixelSize
		}

		public var rawValue: CFDictionary {
			var options: [CFString: Any] = [:]

			options[kCGImageSourceShouldAllowFloat] = self.shouldAllowFloat
			options[kCGImageSourceShouldCache] = self.shouldCache
			options[kCGImageSourceShouldCacheImmediately] = self.shouldDecodeImmediately
			options[kCGImageSourceCreateThumbnailWithTransform] = kCGImageSourceCreateThumbnailWithTransform

			switch self.createThumbnailBehavior {
			case .never:
				break
			case .ifAbsent:
				options[kCGImageSourceCreateThumbnailFromImageIfAbsent] = true
			case .always:
				options[kCGImageSourceCreateThumbnailFromImageAlways] = true
			}

			if let thumbnailMaxPixelSize = thumbnailMaxPixelSize {
				options[kCGImageSourceThumbnailMaxPixelSize] = thumbnailMaxPixelSize
			}

			return options as CFDictionary
		}
	}

	/// Create an image from the image source
	///
	/// - Parameters:
	///   - index: The frame of the image to generate (defaults to 0)
	///   - options: Any options to include when creating the image
	/// - Returns: A CGImage or nil if the underlying file doesn't include an image at that index or has invalid or incomplete data.
	public func cgImage(at index: Int = 0, options: ImageOptions? = nil) -> CGImage? {
		CGImageSourceCreateImageAtIndex(self.cgImageSource, index, options?.rawValue)
	}

	/// Create a thumbnail from the image source.
	///
	/// Depending on the underlying image file and the options passed in, this may load a thumbnail that is embeded in the image, or create one, or return nil.
	///
	/// Typically, it is faster to load a complete image and draw it in a smaller view than it is to generate a thumbnail, both in terms of time and memory. However if you do need to generate a thumbnail, this method can be quit a bit faster and use *a lot* less memory than loading the image and drawing into a context.
	///
	/// - Parameters:
	///   - index: The frame of the image to generate (defaults to 0)
	///   - options: Any options to include when creating the image
	/// - Returns: A thumbnail representation of the image
	public func cgThumbnailImage(at index: Int = 0, options: ImageOptions? = nil) -> CGImage? {
		CGImageSourceCreateThumbnailAtIndex(self.cgImageSource, index, options?.rawValue)
	}

	/// Controls how a thumbnail gets resized to a target size.
	public enum ResizingMode {
		/// Make the thumbnail as big as possible, while completely fitting withint the target size.
		case fit
		/// Make the thumbnail as small as possible, while completely filling the target size.
		case fill
	}

	/// Create a thumbnail from the image source using a destination size.
	///
	/// 	Use this method to create a thumbnail targeted at a specific size. Note that the resulting image will always match the aspect ratio of the original image, so the resulting image size may not match the target size. You can use the `mode` option to control how the target size will be adopted.
	///
	/// - Parameter index: The frame of the image to generate (defaults to 0)
	/// - Parameter size: The target size of the thumbnail.
	/// - Parameter mode: How the thumbnail should be resized.
	/// - Parameter options: Any options to include when creating the image. `thumbnailMaxPixelSize` will be ingnored.
	public func cgThumbnailImage(at index: Int = 0, size: CGSize, mode: ResizingMode = .fit, options: ImageOptions = ImageOptions(shouldCache: true, shouldDecodeImmediately: true, createThumbnailBehavior: .ifAbsent)) -> CGImage? {
		guard let originalSize = self.properties(at: index).imageSize else { return nil }
		let scaledSize: CGSize
		switch mode {
		case .fit:
			scaledSize = originalSize.scaled(toFit: size)
		case .fill:
			scaledSize = originalSize.scaled(toFill: size)
		}

		var options = options
		options.thumbnailMaxPixelSize = max(scaledSize.width, scaledSize.height)

		return self.cgThumbnailImage(at: index, options: options)
	}

	// MARK: - Metadata

	/// The status of an image source.
	///
	/// The status is particularly informative for incremental image sources, but may also be used by clients that provide non-incremental data.
	public var status: CGImageSourceStatus {
		CGImageSourceGetStatus(self.cgImageSource)
	}

	public var error: Error? {
		Error(self.status)
	}

	/// Returns the current status of an image that is at a specified location in an image source.
	///
	/// The status is particularly informative for incremental image sources, but may also be used by clients that provide non-incremental data.
	///
	/// - index: The frame of the image to query.
	/// - Returns: Returns the current status of the image source.
	public func status(at index: Int) -> CGImageSourceStatus {
		CGImageSourceGetStatusAtIndex(self.cgImageSource, index)
	}

	public func error(at index: Int) -> Error? {
		Error(self.status(at: index))
	}

	/// Returns the number of images (not including thumbnails) in the image source.
	///
	/// Typically this is the number of frames in an animated image, or 1 for normal images.
	///
	/// The number of images.
	public var count: Int {
		CGImageSourceGetCount(self.cgImageSource)
	}

	/// The uniform type identifier of the image.
	///
	/// The uniform type identifier (UTI) of the source container can be different from the type of the images in the container. For example, the .icns format supports embedded JPEG2000. The type of the source container is "com.apple.icns" but type of the images is JPEG2000.
	public var typeIdentifier: String? {
		CGImageSourceGetType(self.cgImageSource) as String?
	}

	public func properties(options: ImageOptions? = nil) -> ImageProperties {
		let rawValue = CGImageSourceCopyProperties(cgImageSource, options?.rawValue) as? [CFString: Any] ?? [:]
		return ImageProperties(rawValue: rawValue)
	}

	public func properties(at index: Int, options: ImageOptions? = nil) -> ImageProperties {
		let rawValue = CGImageSourceCopyPropertiesAtIndex(cgImageSource, index, options?.rawValue) as? [CFString: Any] ?? [:]
		return ImageProperties(rawValue: rawValue)
	}

	public static let invalid: ImageSource = {
		let imageSource = ImageSource.incremental()
		imageSource.update(Data(), isFinal: true)
		return imageSource
	}()
}

extension ImageSource: Equatable {
	public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
		lhs.cgImageSource == rhs.cgImageSource
	}
}

extension ImageSource: CustomStringConvertible {
	public var description: String {
		"ImageSource[\(ObjectIdentifier(self))](status: \(self.status))>"
	}
}
