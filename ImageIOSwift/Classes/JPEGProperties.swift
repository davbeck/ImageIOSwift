//
//  JPEGProperties.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import ImageIO


extension ImageProperties {
	public struct JPEGProperties {
		public let rawValue: [CFString:Any]
		
		public init(rawValue: [CFString:Any]) {
			self.rawValue = rawValue
		}
		
		public var xDensity: CGFloat? {
			return rawValue[kCGImagePropertyJFIFXDensity] as? CGFloat
		}
		
		public var yDensity: CGFloat? {
			return rawValue[kCGImagePropertyJFIFYDensity] as? CGFloat
		}
		
		public var orientation: Int? {
			return rawValue[kCGImagePropertyOrientation] as? Int
		}
	}
	
	public var jpeg: JPEGProperties? {
		guard let rawValue = self.rawValue[kCGImagePropertyJFIFDictionary] as? [CFString:Any] else { return nil }
		
		return JPEGProperties(rawValue: rawValue)
	}
}
