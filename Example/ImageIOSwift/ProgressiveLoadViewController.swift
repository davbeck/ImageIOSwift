//
//  DetailViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit
import ImageIOSwift


class ProgressiveLoadViewController: ImageSourceViewController {
	deinit {
		incrementTimer = nil
		task?.cancel()
	}
	
	
	// MARK: - View Lifecycle
	
	lazy var statusLabel = UILabel()
	
	override func viewDidLoad() {
		statusLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: statusLabel, name: "Status")
		
		super.viewDidLoad()
		
		imageSourceView.isAnimationEnabled = true
		
		imageView.removeFromSuperview()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if imageSource?.status != .complete && url.isFileURL {
			incrementTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(incrementImage), userInfo: nil, repeats: true)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		incrementTimer = nil
	}
	
	private var task: ImageSourceDownloader.Task?
	private var progressObserver: NSKeyValueObservation?
	
	override func loadImageSource() {
		guard url.isFileURL else {
			let task = ImageSourceDownloader.shared.download(url)
			imageSource = task.imageSource
			self.task = task
			
			if #available(iOS 11.0, *) {
				progressObserver = task.sessionTask?.progress.observe(\.fractionCompleted, changeHandler: { [weak self] (progress, _) in
					DispatchQueue.main.async {
						let percent = Int(round(progress.fractionCompleted * 100))
						self?.statusLabel.text = "\(task.imageSource.status) (\(percent)%)"
					}
				})
			}
			
			return
		}
		
		
		guard let data = try? Data(contentsOf: url) else {
			print("failed to load image source")
			return
		}
		self.data = data
		
		imageSource = ImageSource.incremental()
		
		progress = 0
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
		self.statusLabel.text = "\(imageSource.status) (\(percent)%)"
	}
}

