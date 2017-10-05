//
//  ProgressiveLoadPickerViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit

class ProgressiveLoadPickerViewController: PickerViewController<ProgressiveLoadViewController> {
	override var options: [String] {
		return [
			"interlaced.jpeg",
			"progressive.jpeg",
			"animated.gif",
			"animated.png",
		]
	}
}
