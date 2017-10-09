//
//  CGImage+Helpers.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import CoreGraphics


extension CGImage {
	public var size: CGSize {
		return CGSize(width: width, height: height)
	}
}
