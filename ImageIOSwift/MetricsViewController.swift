//
//  MetricsViewController.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/6/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit

class MetricsViewController: ImageSourceViewController {
	lazy var sourceTimeLabel = UILabel()
	lazy var sizeTimeLabel = UILabel()
	lazy var imageTimeLabel = UILabel()
	lazy var drawTimeLabel = UILabel()
	lazy var uiImageTimeLabel = UILabel()
	
	override func viewDidLoad() {
		sourceTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: sourceTimeLabel, name: "Create Source")
		sizeTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: sizeTimeLabel, name: "Get Size")
		imageTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: imageTimeLabel, name: "Create Image")
		drawTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: drawTimeLabel, name: "Draw Image")
		uiImageTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: uiImageTimeLabel, name: "UIImage")
		
		super.viewDidLoad()
	}
	
	override func loadImageSource() {
		guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
		
		var start = Date()
		let imageSource = ImageSource(url: url)
		let createSourceDuration = -start.timeIntervalSinceNow
		
		start = Date()
		guard let size = imageSource?.properties(at: 0)?.imageSize else { return }
		let sizeDuration = -start.timeIntervalSinceNow
		
		start = Date()
		guard let image = imageSource?.cgImage(at: 0) else { return }
		let createImageDuration = -start.timeIntervalSinceNow
		
		start = Date()
		_ = imageSource?.cgImage(at: 0)
		let secondCreateImageDuration = -start.timeIntervalSinceNow
		
		UIGraphicsBeginImageContext(size)
		start = Date()
		UIGraphicsGetCurrentContext()?.draw(image, in: CGRect(origin: .zero, size: size))
		let drawDuration = -start.timeIntervalSinceNow
		UIGraphicsEndImageContext()
		
		UIGraphicsBeginImageContext(size)
		start = Date()
		UIGraphicsGetCurrentContext()?.draw(image, in: CGRect(origin: .zero, size: size))
		let secondDrawDuration = -start.timeIntervalSinceNow
		UIGraphicsEndImageContext()
		
		UIGraphicsBeginImageContext(size)
		start = Date()
		UIImage(contentsOfFile: url.path)?.draw(in: CGRect(origin: .zero, size: size))
		let uiImageDrawTime = -start.timeIntervalSinceNow
		UIGraphicsEndImageContext()
		
		
		sourceTimeLabel.text = "\(String(format: "%.4f", createSourceDuration))s"
		sizeTimeLabel.text = "\(String(format: "%.4f", sizeDuration))s"
		imageTimeLabel.text = "\(String(format: "%.4f", createImageDuration))s, \(String(format: "%.4f", secondCreateImageDuration))s"
		drawTimeLabel.text = "\(String(format: "%.4f", drawDuration))s, \(String(format: "%.4f", secondDrawDuration))s"
		uiImageTimeLabel.text = "\(String(format: "%.4f", uiImageDrawTime))s"
		
		self.imageSource = imageSource
	}
}
