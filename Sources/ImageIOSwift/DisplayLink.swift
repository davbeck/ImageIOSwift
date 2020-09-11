import Foundation
#if canImport(QuartzCore)
	import QuartzCore
#endif

class DisplayLink {
	static var currentTime: TimeInterval {
		#if canImport(QuartzCore)
			return CACurrentMediaTime()
		#else
			return NSDate().timeIntervalSinceReferenceDate
		#endif
	}
	
	#if os(iOS) || os(tvOS)
		private lazy var link = CADisplayLink(target: self, selector: #selector(displayLinkFired))
	#else
		private var timeInterval: TimeInterval
		private var timer: Timer? {
			didSet {
				oldValue?.invalidate()
			}
		}
	#endif
	
	func start() {
		#if os(iOS) || os(tvOS)
			self.link.add(to: .main, forMode: .default)
		#else
		#endif
		
		self.isPaused = false
	}
	
	public var isPaused: Bool = true {
		didSet {
			#if os(iOS) || os(tvOS)
				self.link.isPaused = self.isPaused
			#else
				if !self.isPaused {
					self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
				} else if self.timer == nil {
					self.timer = nil
				}
			#endif
		}
	}
	
	public func invalidate() {
		#if os(iOS) || os(tvOS)
			self.link.invalidate()
		#else
			self.timer = nil
		#endif
	}
	
	#if os(iOS) || os(tvOS)
		@objc private func displayLinkFired(_: CADisplayLink) {
			if #available(iOS 10.0, tvOS 10.0, *) {
				self.onFire(self.link.targetTimestamp)
			} else {
				self.onFire(self.link.timestamp)
			}
		}
		
	#else
		@objc private func timerFired() {
			self.onFire(DisplayLink.currentTime)
		}
	#endif
	
	public var preferredFramesPerSecond: Int
	
	public var onFire: (TimeInterval) -> Void
	
	public init(preferredFramesPerSecond: Int = 0, onFire: @escaping ((TimeInterval) -> Void)) {
		self.preferredFramesPerSecond = preferredFramesPerSecond
		self.onFire = onFire
		
		#if os(iOS) || os(tvOS)
			if #available(iOS 10.0, tvOS 10.0, macCatalyst 13.0, *) {
				self.link.preferredFramesPerSecond = preferredFramesPerSecond
			}
		#else
			self.timeInterval = preferredFramesPerSecond == 0 ? 1 / 60 : 1 / TimeInterval(preferredFramesPerSecond)
		#endif
	}
	
	deinit {
		invalidate()
	}
}
