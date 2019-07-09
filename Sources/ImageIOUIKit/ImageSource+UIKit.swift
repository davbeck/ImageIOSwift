//
//  ImageSource+UIKit.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

#if canImport(UIKit)
import ImageIOSwift
import UIKit


extension ImageSource {
	public func image(at index: Int = 0, options: ImageOptions? = nil) -> UIImage? {
		guard let cgImage = self.cgImage(at: index, options: options) else { return nil }
		
		let exifOrientation = properties(at: index, options: options).orientation
		let orientation = UIImage.Orientation(exifOrientation: exifOrientation)
		
		return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
	}
	
	public func thumbnailImage(at index: Int = 0, options: ImageOptions? = nil) -> UIImage? {
		guard let cgImage = self.cgThumbnailImage(at: index, options: options) else { return nil }
		
		let exifOrientation = properties(at: index, options: options).orientation
		let orientation = UIImage.Orientation(exifOrientation: exifOrientation)
		
		return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
	}
}
#endif
