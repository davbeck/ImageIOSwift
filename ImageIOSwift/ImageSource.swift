//
//  ImageSource.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import Foundation
import ImageIO


/// An interface to an image file including metadata
///
/// You can think of `CG/NS/UIImage` as a single frame of pixels. `ImageSource` sits a level below that, providing access to almost anything an image *file* provides, including metadata and multiple representations. For instance, animated images have multiple image frames as well as timing metadata.
public struct ImageSource {
	/// The underlying image source
	public let cgImageSource: CGImageSource
	
	public struct CreateOptions {
		public var typeIdentifierHint: String?
		
		public init(typeIdentifierHint: String? = nil) {
			self.typeIdentifierHint = typeIdentifierHint
		}
		
		public var rawValue: CFDictionary {
			var options: [CFString:Any] = [:]
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
	public init?(url: URL, options: CreateOptions? = nil) {
		guard let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, options?.rawValue) else { return nil }
		
		self.init(cgImageSource)
	}
	
	/// Create an image source from data in memory
	///
	/// Unlike `incremental(options:)`, this assumes the data represents the complete file from creation.
	///
	/// - Parameter data: The data representation of the image file.
	/// - Parameter options: Options to use for the created image source.
	public init?(data: Data, options: CreateOptions? = nil) {
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
	
	/// Update an incremental image source with more data
	///
	/// When more data is available for an image, call this with *all of the available data so far*.
	///
	/// - Parameters:
	///   - data: All data available at this time.
	///   - isFinal: Set this to true when the file has been completely loaded.
	public func update(_ data: Data, isFinal: Bool) {
		CGImageSourceUpdateData(cgImageSource, data as CFData, isFinal)
		
		DispatchQueue.global().async {
			// avoid deadlock
			NotificationCenter.default.post(name: ImageSource.didUpdateData, object: self.cgImageSource)
		}
	}
	
	
	// MARK: - Image Generation
	
	public struct ImageOptions {
		public var shouldAllowFloat: Bool = false
		public var shouldCache: Bool = true
		public var createThumbnailFromImageIfAbsent: Bool = false
		public var createThumbnailFromImageAlways: Bool = false
		public var thumbnailMaxPixelSize: CGFloat?
		
		public init() {
			
		}
		
		public var rawValue: CFDictionary {
			var options: [CFString:Any] = [:]
			options[kCGImageSourceShouldAllowFloat] = shouldAllowFloat
			options[kCGImageSourceShouldCache] = shouldCache
			options[kCGImageSourceCreateThumbnailFromImageIfAbsent] = createThumbnailFromImageIfAbsent
			options[kCGImageSourceCreateThumbnailFromImageAlways] = createThumbnailFromImageAlways
			
			if let thumbnailMaxPixelSize = thumbnailMaxPixelSize {
				options[kCGImageSourceThumbnailMaxPixelSize] = thumbnailMaxPixelSize
			}
			
			return options as CFDictionary
		}
	}
	
	/// Create an image from the image source
	///
	/// This method is fairly cheap to call because the returned CGImage is lazily loaded when it is first drawn.
	///
	/// - Parameters:
	///   - index: The frame of the image to generate (defaults to 0)
	///   - options: Any options to include when creating the image
	/// - Returns: A CGImage or nil if the underlying file doesn't include an image at that index or has invalide or incomplete data
	public func cgImage(at index: Int = 0, options: ImageOptions? = nil) -> CGImage? {
		return CGImageSourceCreateImageAtIndex(cgImageSource, index, options?.rawValue)
	}
	
	/// Create a thumbnail from the image source
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
		return CGImageSourceCreateThumbnailAtIndex(cgImageSource, index, options?.rawValue)
	}
	
	
	// MARK: - Metadata
	
	/// Return the status of an image source.
	///
	/// The status is particularly informative for incremental image sources, but may also be used by clients that provide non-incremental data.
	///
	/// - Returns: Returns the current status of the image source.
	public func status() -> CGImageSourceStatus {
		return CGImageSourceGetStatus(cgImageSource)
	}
	
	/// Returns the current status of an image that is at a specified location in an image source.
	///
	/// The status is particularly informative for incremental image sources, but may also be used by clients that provide non-incremental data.
	///
	/// - index: The frame of the image to query.
	/// - Returns: Returns the current status of the image source.
	public func status(at index: Int) -> CGImageSourceStatus {
		return CGImageSourceGetStatusAtIndex(cgImageSource, index)
	}
	
	/// Returns the number of images (not including thumbnails) in the image source.
	///
	/// Typically this is the number of frames in an animated image, or 1 for normal images.
	///
	/// The number of images.
	public var count: Int {
		return CGImageSourceGetCount(cgImageSource)
	}
	
	public func properties(options: ImageOptions? = nil) -> ImageProperties? {
		guard let rawValue = CGImageSourceCopyProperties(cgImageSource, options?.rawValue) as? [CFString:Any] else { return nil }
		
		return ImageProperties(rawValue: rawValue)
	}
	
	public func properties(at index: Int, options: ImageOptions? = nil) -> ImageProperties? {
		guard let rawValue = CGImageSourceCopyPropertiesAtIndex(cgImageSource, index, options?.rawValue) as? [CFString:Any] else { return nil }
		
		return ImageProperties(rawValue: rawValue)
	}
}


extension ImageSource: Equatable {
	public static func ==(lhs: ImageSource, rhs: ImageSource) -> Bool {
		return lhs.cgImageSource == rhs.cgImageSource
	}
}
