//
//  Properties.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import Foundation
import ImageIO


extension ImageSource {
	public struct Properties {
		public let rawValue: [CFString:Any]
		
		public init(rawValue: [CFString:Any]) {
			self.rawValue = rawValue
		}
		
		
		// MARK: - Top level
		
		public var fileSize: Int? {
			return rawValue[kCGImagePropertyFileSize] as? Int
		}
		
		public var pixelWidth: CGFloat? {
			guard let value = rawValue[kCGImagePropertyPixelWidth] as? Double else { return nil }
			return CGFloat(value)
		}
		
		public var pixelHeight: CGFloat? {
			guard let value = rawValue[kCGImagePropertyPixelHeight] as? Double else { return nil }
			return CGFloat(value)
		}
		
		public var orientation: Int? {
			return rawValue[kCGImagePropertyOrientation] as? Int
		}
		
		public var imageSize: CGSize? {
			guard var width = pixelWidth, var height = pixelHeight else { return nil }
			
			switch orientation ?? 1 {
			case 6...8: // http://magnushoff.com/jpeg-orientation.html
				swap(&width, &height)
			default: break
			}
			
			return CGSize(width: width, height: height)
		}
		
		
		// MARK: - Aggregate
		
		public var loopCount: Int {
			return gif?.loopCount ?? png?.loopCount ?? 1
		}
		
		public var clampedDelayTime: Double? {
			return gif?.clampedDelayTime ?? png?.clampedDelayTime
		}
		
		public var unclampedDelayTime: Double? {
			return gif?.unclampedDelayTime ?? png?.unclampedDelayTime
		}
		
		public var delayTime: Double? {
			return gif?.delayTime ?? png?.delayTime
		}
		
		
		// MARK: -
		
		public struct GIFProperties {
			public let rawValue: [CFString:Any]
			
			public init(rawValue: [CFString:Any]) {
				self.rawValue = rawValue
			}
			
			public var loopCount: Int {
				return rawValue[kCGImagePropertyGIFLoopCount] as? Int ?? 1
			}
			
			public var clampedDelayTime: Double? {
				guard
					let delay = rawValue[kCGImagePropertyGIFDelayTime] as? Double,
					delay > 0
				else { return nil }
				return delay
			}
			
			public var unclampedDelayTime: Double? {
				guard
					let delay = rawValue[kCGImagePropertyGIFUnclampedDelayTime] as? Double,
					delay > 0
					else { return nil }
				return delay
			}
			
			public var delayTime: Double? {
				return unclampedDelayTime ?? clampedDelayTime
			}
			
			public var hasGlobalColorMap: Bool {
				return rawValue[kCGImagePropertyGIFHasGlobalColorMap] as? Bool ?? false
			}
		}
		
		public var gif: GIFProperties? {
			guard let rawValue = self.rawValue[kCGImagePropertyGIFDictionary] as? [CFString:Any] else { return nil }
			
			return GIFProperties(rawValue: rawValue)
		}
		
		
		// MARK: -
		
		public struct PNGProperties {
			public let rawValue: [CFString:Any]
			
			public init(rawValue: [CFString:Any]) {
				self.rawValue = rawValue
			}
			
			public var loopCount: Int {
				return rawValue[kCGImagePropertyAPNGLoopCount] as? Int ?? 1
			}
			
			public var clampedDelayTime: Double? {
				guard
					let delay = rawValue[kCGImagePropertyAPNGDelayTime] as? Double,
					delay > 0
					else { return nil }
				return delay
			}
			
			public var unclampedDelayTime: Double? {
				guard
					let delay = rawValue[kCGImagePropertyAPNGUnclampedDelayTime] as? Double,
					delay > 0
					else { return nil }
				return delay
			}
			
			public var delayTime: Double? {
				return unclampedDelayTime ?? clampedDelayTime
			}
		}
		
		public var png: PNGProperties? {
			guard let rawValue = self.rawValue[kCGImagePropertyPNGDictionary] as? [CFString:Any] else { return nil }
			
			return PNGProperties(rawValue: rawValue)
		}
	}
}
