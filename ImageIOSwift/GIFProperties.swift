//
//  GIFProperties.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import ImageIO


extension ImageProperties {
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
}
