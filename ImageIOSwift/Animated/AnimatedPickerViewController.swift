//
//  AnimatedPickerViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit


class AnimatedPickerViewController: PickerViewController<AnimatedViewController> {
	override var options: [String] {
		return [
			"animated.gif",
			"animated.png",
		]
	}
}
