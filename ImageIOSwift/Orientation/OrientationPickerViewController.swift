//
//  OrientationPickerViewController.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit


class OrientationPickerViewController: PickerViewController<OrientationViewController> {
	override var options: [String] {
		return (1...8).map({ "Landscape_\($0).jpg" }) +
			(1...8).map({ "Portrait_\($0).jpg" })
	}
}
