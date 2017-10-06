//
//  Properties.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import Foundation
import ImageIO


public struct ImageProperties {
	public let rawValue: [CFString:Any]
	
	public init(rawValue: [CFString:Any]) {
		self.rawValue = rawValue
	}
	
	
	// MARK: - Top level
	
	public var fileSize: Int? {
		return rawValue[kCGImagePropertyFileSize] as? Int
	}
	
	public var pixelWidth: CGFloat? {
		return rawValue[kCGImagePropertyPixelWidth] as? CGFloat
	}
	
	public var pixelHeight: CGFloat? {
		return rawValue[kCGImagePropertyPixelHeight] as? CGFloat
	}
	
	public var imageSize: CGSize? {
		guard var width = pixelWidth, var height = pixelHeight else { return nil }
		
		switch orientation {
		case 6...8: // http://magnushoff.com/jpeg-orientation.html
			swap(&width, &height)
		default: break
		}
		
		return CGSize(width: width, height: height)
	}
	
	public var orientation: Int {
		return rawValue[kCGImagePropertyOrientation] as? Int ?? tiff?.orientation ?? iptc?.orientation ?? 1
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
}
