//
//  AnimatedViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit

class AnimatedViewController: ImageSourceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
		
		imageSourceView.isAnimationEnabled = true
    }
}
