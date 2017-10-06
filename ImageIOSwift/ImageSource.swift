//
//  ImageSource.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import Foundation
import ImageIO


public struct ImageSource {
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
	
	public init?(url: URL, options: CreateOptions? = nil) {
		guard let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, options?.rawValue) else { return nil }
		
		self.init(cgImageSource)
	}
	
	public static func incremental(options: CreateOptions? = nil) -> ImageSource {
		let cgImageSource = CGImageSourceCreateIncremental(options?.rawValue)
		
		return ImageSource(cgImageSource)
	}
	
	
	// MARK: - Incremental
	
	public static let didUpdateData = Notification.Name(rawValue: "ImageIOSwift.ImageSource.didUpdateData")
	
	public func update(_ data: Data, isFinal: Bool) {
		CGImageSourceUpdateData(cgImageSource, data as CFData, isFinal)
		
		NotificationCenter.default.post(name: ImageSource.didUpdateData, object: cgImageSource)
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
	
	public func cgImage(at index: Int, options: ImageOptions? = nil) -> CGImage? {
		return CGImageSourceCreateImageAtIndex(cgImageSource, index, options?.rawValue)
	}
	
	public func cgThumbnailImage(at index: Int, options: ImageOptions? = nil) -> CGImage? {
		return CGImageSourceCreateThumbnailAtIndex(cgImageSource, index, options?.rawValue)
	}
	
	
	// MARK: - Metadata
	
	public func status() -> CGImageSourceStatus {
		return CGImageSourceGetStatus(cgImageSource)
	}
	
	public func status(at index: Int) -> CGImageSourceStatus {
		return CGImageSourceGetStatusAtIndex(cgImageSource, index)
	}
	
	public var count: Int {
		switch self.status(at: 0) {
		case .readingHeader, .unexpectedEOF:
			return 0
		default:
			return CGImageSourceGetCount(cgImageSource)
		}
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
