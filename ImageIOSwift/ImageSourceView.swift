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
		return isShown && isAnimationEnabled && imageSource.count > 1
	}
	
	private func updateAnimation() {
		if let imageSource = imageSource, shouldAnimate() {
			if imageSource.status() == .complete {
				if animationController == nil {
					animationController = AnimationController(view: self)
				}
			} else {
				self.displayedIndex = imageSource.count - 1
			}
		} else {
			animationController = nil
		}
	}
	
	public func restartAnimation() {
		animationController = AnimationController(view: self)
	}
	
	
	// MARK: - Initialization
	
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
	
	
	// MARK: - Updating
	
	func updateImage() {
		let image = imageSource?.cgImage(at: displayedIndex)
		self.layer.contents = image
	}
}
