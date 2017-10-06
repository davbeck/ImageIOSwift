//
//  IPTCProperties.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import ImageIO


extension ImageProperties {
	public struct IPTCProperties {
		public let rawValue: [CFString:Any]
		
		public init(rawValue: [CFString:Any]) {
			self.rawValue = rawValue
		}
		
		public var orientation: Int? {
			return rawValue[kCGImagePropertyIPTCImageOrientation] as? Int
		}
	}
	
	public var iptc: IPTCProperties? {
		guard let rawValue = self.rawValue[kCGImagePropertyIPTCDictionary] as? [CFString:Any] else { return nil }
		
		return IPTCProperties(rawValue: rawValue)
	}
}
