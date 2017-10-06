//
//  TIFFProperties.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import ImageIO


extension ImageProperties {
	public struct TIFFProperties {
		public let rawValue: [CFString:Any]
		
		public init(rawValue: [CFString:Any]) {
			self.rawValue = rawValue
		}
		
		public var orientation: Int? {
			return rawValue[kCGImagePropertyTIFFOrientation] as? Int
		}
		
		public var xResolution: Int? {
			return rawValue[kCGImagePropertyTIFFXResolution] as? Int
		}
		
		public var yResolution: Int? {
			return rawValue[kCGImagePropertyTIFFYResolution] as? Int
		}
	}
	
	public var tiff: TIFFProperties? {
		guard let rawValue = self.rawValue[kCGImagePropertyTIFFDictionary] as? [CFString:Any] else { return nil }
		
		return TIFFProperties(rawValue: rawValue)
	}
}
