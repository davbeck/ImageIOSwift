//
//  ImageSourceView.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit


public class ImageSourceView: UIView {
	private let notificationCenter = NotificationCenter.default
	private var notificationObservers: [NSObjectProtocol] = []
	
	public var imageSource: ImageSource? {
		didSet {
			for observer in notificationObservers {
				notificationCenter.removeObserver(observer)
			}
			
			animationController = nil
			updateAnimation()
			updateImage()
			
			if let imageSource = imageSource {
				notificationObservers.append(notificationCenter.addObserver(forName: ImageSource.didUpdateData, object: imageSource.cgImageSource, queue: .main, using: { [weak self] (notification) in
					self?.updateImage()
					self?.updateAnimation()
				}))
			}
		}
	}
	
	private var displayedIndex: Int = 0 {
		didSet {
			guard displayedIndex != oldValue else { return }
			
			self.updateImage()
		}
	}
	
	private var displayedImage: CGImage? {
		didSet {
			displayView.layer.contents = displayedImage
		}
	}
	
	
	// MARK: - Initialization
	
	
	/// Used to display the current CGImage
	///
	/// While you could set the CGImage directly on the view's primary layer, any transformations done to the view would interfere with the transformations set for the images orientation.
	private let displayView = UIView()
	
	private func commonInit() {
		self.addSubview(displayView)
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		commonInit()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		commonInit()
	}
	
	deinit {
		for observer in notificationObservers {
			notificationCenter.removeObserver(observer)
		}
	}
	
	public override func didMoveToWindow() {
		super.didMoveToWindow()
		updateAnimation()
	}
	
	public override func didMoveToSuperview() {
		super.didMoveToSuperview()
		updateAnimation()
	}
	
	public override var alpha: CGFloat {
		didSet {
			updateAnimation()
		}
	}
	
	public override var isHidden: Bool {
		didSet {
			updateAnimation()
		}
	}
	
	
	// MARK: - Layout
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		displayView.frame = bounds
	}
	
	public override var intrinsicContentSize: CGSize {
		return imageSource?.properties(at: displayedIndex)?.imageSize ??
			CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
	}
	
	public override var contentMode: UIViewContentMode {
		didSet {
			displayView.contentMode = contentMode
		}
	}
	
	
	// MARK: - Updating
	
	func updateImage() {
		self.displayedImage = imageSource?.cgImage(at: displayedIndex)
		
		self.invalidateIntrinsicContentSize()
		
		switch imageSource?.properties(at: displayedIndex)?.orientation ?? 1 {
		case 2:
			self.displayView.transform = CGAffineTransform(scaleX: -1, y: 1)
		case 3:
			self.displayView.transform = CGAffineTransform(scaleX: -1, y: -1)
		case 4:
			self.displayView.transform = CGAffineTransform(scaleX: 1, y: -1)
		case 5:
			self.displayView.transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2)
		case 6:
			self.displayView.transform = CGAffineTransform(rotationAngle: .pi / 2)
		case 7:
			self.displayView.transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: -.pi / 2)
		case 8:
			self.displayView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
		default: // 1
			self.displayView.transform = CGAffineTransform.identity
		}
	}
	
	
	// MARK: - Animation
	
	private class AnimationController {
		private var displayLink: CADisplayLink?
		
		private var hasStartedAnimating: Bool = false
		private var hasFinishedAnimating: Bool = false
		private var isInfiniteLoop: Bool = false
		private var remainingLoopCount: Int = 0
		private var elapsedTime: Double = 0.0
		private var previousTime: Double = 0.0
		
		weak var view: ImageSourceView?
		init(view: ImageSourceView) {
			self.view = view
			
			self.displayLink = CADisplayLink(callback: { [weak self] link in
				self?.displayLinkFired(link)
			})
			displayLink?.add(to: RunLoop.main, forMode: .commonModes)
			if #available(iOS 10.0, *) {
				displayLink?.preferredFramesPerSecond = 60
			}
		}
		
		deinit {
			invalidate()
		}
		
		func invalidate() {
			view = nil
			displayLink?.invalidate()
		}
		
		func reset() {
			hasStartedAnimating = false
			hasFinishedAnimating = false
			if let count = view?.imageSource?.properties()?.loopCount {
				isInfiniteLoop = count == 0
				remainingLoopCount = count
			} else {
				isInfiniteLoop = false
				remainingLoopCount = 0
			}
			elapsedTime = 0.0
			previousTime = 0.0
		}
		
		@objc func displayLinkFired(_ link: CADisplayLink) {
			guard
				let view = view,
				view.shouldAnimate(),
				let image = view.imageSource
			else { return }
			
			let timestamp = link.timestamp
			
			// If this is the first callback, set things up
			if !hasStartedAnimating {
				elapsedTime = 0.0
				previousTime = timestamp
				hasStartedAnimating = true
			}
			
			let currentDelayTime = image.properties(at: view.displayedIndex)?.delayTime ?? 0
			elapsedTime += timestamp - previousTime
			previousTime = timestamp
			
			// Aaccount for big gaps in playback by just resuming from now
			// e.g. user presses home button and comes back after a while.
			// Allow for the possibility of the current delay time being relatively long
			if elapsedTime >= max(10.0, currentDelayTime + 1.0) {
				elapsedTime = 0.0
			}
			
			var displayedIndex = view.displayedIndex
			while elapsedTime >= currentDelayTime {
				elapsedTime -= currentDelayTime
				displayedIndex += 1
				if displayedIndex >= image.count {
					// Time to loop. Start infinite loops over, otherwise decrement loop count and stop if done
					if isInfiniteLoop {
						displayedIndex = 0
					} else {
						remainingLoopCount -= 1
						if remainingLoopCount == 0 {
							hasFinishedAnimating = true
							DispatchQueue.main.async {
								view.updateAnimation()
							}
						} else {
							displayedIndex = 0
						}
					}
				}
			}
			view.displayedIndex = displayedIndex
		}
	}
	
	private var animationController: AnimationController? = nil {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	public var isAnimationEnabled: Bool = false {
		didSet {
			guard isAnimationEnabled != oldValue else { return }
			
			self.updateAnimation()
		}
	}
	
	private func shouldAnimate() -> Bool {
		guard let imageSource = imageSource else { return false }
		
		let isShown = window != nil && superview != nil && !isHidden && alpha > 0.0
		return isShown && isAnimationEnabled && imageSource.count > 1 && imageSource.status() == .complete
	}
	
	private func updateAnimation() {
		if shouldAnimate() {
			if animationController == nil {
				animationController = AnimationController(view: self)
			}
		} else {
			animationController = nil
		}
	}
	
	public func restartAnimation() {
		animationController = AnimationController(view: self)
	}
}
