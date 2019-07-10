#if canImport(UIKit)
    import ImageIOSwift
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
                updateImage(asynchronously: false)
                updateProperties()
                
                if let imageSource = _imageSource {
                    notificationObservers.append(notificationCenter.addObserver(forName: ImageSource.didUpdateData, object: imageSource, queue: .main, using: { [weak self] _ in
                        self?.updateImage(asynchronously: true)
                        self?.updateProperties()
                        self?.updateAnimation()
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
                guard self.displayedIndex != oldValue else { return }
                
                self.updateImage()
            }
        }
        
        @objc open private(set) dynamic var displayedImage: CGImage? {
            get {
                return self.displayView.layer.contents as! CGImage?
            }
            set {
                if displayedImage != newValue {
                    willChangeValue(for: \.displayedImage)
                    self.displayView.layer.contents = newValue
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
            self.addSubview(self.displayView)
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.commonInit()
        }
        
        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            
            self.commonInit()
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
            self.updateAnimation()
        }
        
        open override func didMoveToSuperview() {
            super.didMoveToSuperview()
            self.updateAnimation()
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
            
            self.displayView.frame = bounds
        }
        
        open override var intrinsicContentSize: CGSize {
            return imageSource?.properties().imageSize ??
                CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        open override var contentMode: UIView.ContentMode {
            didSet {
                self.displayView.contentMode = self.contentMode
            }
        }
        
        // MARK: - Updating
        
        private let queue = DispatchQueue(label: "ImageSourceView")
        
        private func updateImage(asynchronously: Bool = true) {
            if asynchronously {
                queue.async {
                    var options = ImageSource.ImageOptions()
                    options.shouldDecodeImmediately = true
                    let image = self.imageSource?.cgImage(at: self.displayedIndex, options: options)
                    
                    DispatchQueue.main.async {
                        self.displayedImage = image
                    }
                }
            } else {
                queue.sync {
                    self.displayedImage = self.imageSource?.cgImage(at: self.displayedIndex)
                }
            }
        }
        
        private func updateProperties() {
            self.invalidateIntrinsicContentSize()
            self.displayView.transform = self.imageSource?.properties().transform ?? CGAffineTransform.identity
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
                if #available(iOS 10.0, *) {
                    self.displayLink?.preferredFramesPerSecond = view.imageSource?.preferredFramesPerSecond ?? 0
                }
                self.displayLink?.add(to: RunLoop.main, forMode: .common)
                if #available(iOS 10.0, *) {
                    displayLink?.preferredFramesPerSecond = 60
                }
            }
            
            deinit {
                invalidate()
            }
            
            func invalidate() {
                self.view = nil
                self.displayLink?.invalidate()
            }
            
            func reset() {
                self.hasStartedAnimating = false
                self.hasFinishedAnimating = false
                if let count = view?.imageSource?.properties().loopCount {
                    self.isInfiniteLoop = count == 0
                    self.remainingLoopCount = count
                } else {
                    self.isInfiniteLoop = false
                    self.remainingLoopCount = 0
                }
                self.elapsedTime = 0.0
                self.previousTime = 0.0
            }
            
            @objc func displayLinkFired(_ link: CADisplayLink) {
                guard
                    let view = view,
                    view.shouldAnimate(),
                    let image = view.imageSource
                else { return }
                
                let timestamp = link.timestamp
                
                // If this is the first callback, set things up
                if !self.hasStartedAnimating {
                    self.elapsedTime = 0.0
                    self.previousTime = timestamp
                    self.hasStartedAnimating = true
                }
                
                let currentDelayTime = image.properties(at: view.displayedIndex).delayTime ?? 0
                self.elapsedTime += timestamp - self.previousTime
                self.previousTime = timestamp
                
                // Aaccount for big gaps in playback by just resuming from now
                // e.g. user presses home button and comes back after a while.
                // Allow for the possibility of the current delay time being relatively long
                if self.elapsedTime >= max(10.0, currentDelayTime + 1.0) {
                    self.elapsedTime = 0.0
                }
                
                var displayedIndex = view.displayedIndex
                while self.elapsedTime >= currentDelayTime {
                    self.elapsedTime -= currentDelayTime
                    displayedIndex += 1
                    if displayedIndex >= image.count {
                        // Time to loop. Start infinite loops over, otherwise decrement loop count and stop if done
                        if self.isInfiniteLoop {
                            displayedIndex = 0
                        } else {
                            self.remainingLoopCount -= 1
                            if self.remainingLoopCount == 0 {
                                self.hasFinishedAnimating = true
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
        
        private var animationController: AnimationController? {
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
            
            let isShown = window != nil && superview != nil && !self.isHidden && self.alpha > 0.0
            return isShown && self.isAnimationEnabled && imageSource.count > 1 && imageSource.status == .complete
        }
        
        private func updateAnimation() {
            if self.shouldAnimate() {
                if self.animationController == nil {
                    self.animationController = AnimationController(view: self)
                }
            } else {
                self.animationController = nil
            }
        }
        
        public func restartAnimation() {
            self.animationController = AnimationController(view: self)
        }
    }
#endif
