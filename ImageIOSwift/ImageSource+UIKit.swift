//
//  ImageSource+UIKit.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit


extension ImageSource {
	public func image(at index: Int, options: ImageOptions? = nil) -> UIImage? {
		guard let cgImage = self.cgImage(at: index, options: options) else { return nil }
		
		let exifOrientation = properties(at: index, options: options)?.orientation ?? 1
		let orientation = UIImageOrientation(exifOrientation: exifOrientation)
		
		return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
	}
}
