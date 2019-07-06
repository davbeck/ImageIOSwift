//
//  ImageSourceView.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

#if canImport(UIKit)
import UIKit


open class ImageSourceView: UIView {
	private let notificationCenter = NotificationCenter.default
	private var notificationObservers: [NSObjectProtocol] = []
	
	private var _imageSource: ImageSource? {
		didSet {
			guard _imageSource != oldValue else { return }
			
			for observer in notificationObservers {
				notificationCenter.removeObserver(observer)
			}
			
			animationController = nil
			displayedIndex = 0
			updateAnimation()
			updateImage()
			
			if let imageSource = _imageSource {
				notificationObservers.append(notificationCenter.addObserver(forName: ImageSource.didUpdateData, object: imageSource, queue: nil, using: { [weak self] (notification) in
					if Thread.isMainThread {
						self?.updateImage()
						self?.updateAnimation()
					} else {
						DispatchQueue.main.async { // must be async
							self?.updateImage()
							self?.updateAnimation()
						}
					}
				}))
			}
		}
	}
	
	open var imageSource: ImageSource? {
		get {
			return _imageSource
		}
		set {
			task = nil
			self._imageSource = newValue
		}
	}
	
	open var displayedIndex: Int = 0 {
		didSet {
			guard displayedIndex != oldValue else { return }
			
			self.updateImage()
		}
	}
	
	@objc open private(set) dynamic var displayedImage: CGImage? {
		get {
			return displayView.layer.contents as! CGImage?
		}
		set {
			if displayedImage != newValue {
				willChangeValue(for: \.displayedImage)
				displayView.layer.contents = newValue
				didChangeValue(for: \.displayedImage)
			}
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
		
		task?.cancel()
		
		animationController?.invalidate()
	}
	
	open override func didMoveToWindow() {
		super.didMoveToWindow()
		updateAnimation()
	}
	
	open override func didMoveToSuperview() {
		super.didMoveToSuperview()
		updateAnimation()
	}
	
	open override var alpha: CGFloat {
		didSet {
			updateAnimation()
		}
	}
	
	open override var isHidden: Bool {
		didSet {
			updateAnimation()
		}
	}
	
	
	// MARK: - Layout
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		displayView.frame = bounds
	}
	
	open override var intrinsicContentSize: CGSize {
		return imageSource?.properties(at: displayedIndex).imageSize ??
			CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
	}
	
	open override var contentMode: UIViewContentMode {
		didSet {
			displayView.contentMode = contentMode
		}
	}
	
	
	// MARK: - Updating
	
	private func updateImage() {
		self.displayedImage = imageSource?.cgImage(at: displayedIndex)
		
		self.invalidateIntrinsicContentSize()
		
		self.displayView.transform = imageSource?.properties(at: displayedIndex).transform ?? CGAffineTransform.identity
	}
	
	
	// MARK: - URL Loading
	
	public var task: ImageSourceDownloader.Task? {
		didSet {
			guard task !== oldValue else { return }
			oldValue?.cancel()
			
			_imageSource = task?.imageSource
		}
	}
	
	open func load(_ url: URL, with downloader: ImageSourceDownloader = .shared, completionHandler: ((ImageSource?, Data?, URLResponse?, Error?) -> Void)? = nil) {
		self.task = downloader.download(url, completionHandler: completionHandler)
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
			if let count = view?.imageSource?.properties().loopCount {
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
			
			let currentDelayTime = image.properties(at: view.displayedIndex).delayTime ?? 0
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
	
	open func shouldAnimate() -> Bool {
		guard let imageSource = imageSource else { return false }
		
		let isShown = window != nil && superview != nil && !isHidden && alpha > 0.0
		return isShown && isAnimationEnabled && imageSource.count > 1 && imageSource.status == .complete
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
#endif
