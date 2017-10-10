//
//  UIImageOrientation+Helpers.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

#if os(iOS)
import UIKit


extension UIImageOrientation {
	public init(exifOrientation: Int) {
		switch exifOrientation {
		case 2:
			self = .upMirrored
		case 3:
			self = .down
		case 4:
			self = .downMirrored
		case 5:
			self = .leftMirrored
		case 6:
			self = .right
		case 7:
			self = .rightMirrored
		case 8:
			self = .left
		default: // 1
			self = .up
		}
	}
}
#endif
