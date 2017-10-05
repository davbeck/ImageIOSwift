//
//  DetailViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit

class ProgressiveLoadViewController: ImageSourceViewController {
	deinit {
		incrementTimer = nil
	}
	
	
	// MARK: - View Lifecycle
	
	lazy var statusLabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard
			let url = Bundle.main.url(forResource: filename, withExtension: nil),
			let data = try? Data(contentsOf: url)
			else {
				print("failed to load image source")
				return
		}
		self.data = data
		
		imageSourceView.imageSource = ImageSource.incremental()
		
		progress = 0
		incrementTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(incrementImage), userInfo: nil, repeats: true)
	}
	
	private var data = Data()
	
	private var progress: Int = 0
	
	private var incrementTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	@objc func incrementImage() {
		guard let imageSource = imageSourceView.imageSource else { return }
		
		progress += 500
		let chunk = data.prefix(progress)
		if chunk.count == data.count {
			incrementTimer = nil
		}
		
		imageSource.update(Data(chunk), isFinal: chunk.count == data.count)
		
		let percent = Int(round(Double(chunk.count) / Double(data.count) * 100))
		self.statusLabel.text = "\(imageSource.status(at: 0)) (\(percent)%)"
	}
}

