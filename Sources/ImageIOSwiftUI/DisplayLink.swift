import Combine
import Foundation
import QuartzCore

struct DisplayLink: Publisher {
	class Subscription<S>: Combine.Subscription where S: Subscriber, Never == S.Failure, CFTimeInterval == S.Input {
		#if os(iOS)
			private lazy var link = CADisplayLink(target: self, selector: #selector(displayLinkFired))
		#else
			private var timeInterval: TimeInterval
			private var timer: Timer? {
				didSet {
					oldValue?.invalidate()
				}
			}
		#endif
		private let subscriber: AnySubscriber<CFTimeInterval, Never>
		
		private var demand: Subscribers.Demand = .unlimited {
			didSet {
				#if os(iOS)
					self.link.isPaused = self.demand == .none
				#else
					if self.demand == .none {
						self.timer = nil
					} else if self.timer == nil {
						self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
					}
				#endif
			}
		}
		
		fileprivate init(subscriber: S, preferredFramesPerSecond: Int) {
			self.subscriber = AnySubscriber(subscriber)
			#if os(iOS)
				self.link.preferredFramesPerSecond = preferredFramesPerSecond
				self.link.add(to: .main, forMode: .default)
			#else
				self.timeInterval = preferredFramesPerSecond == 0 ? 1 / 60 : 1 / TimeInterval(preferredFramesPerSecond)
			#endif
		}
		
		deinit {
			#if os(iOS)
				link.invalidate()
			#else
				timer?.invalidate()
			#endif
		}
		
		func request(_ demand: Subscribers.Demand) {
			self.demand = demand
		}
		
		func cancel() {
			self.demand = .none
		}
		
		#if os(iOS)
			@objc private func displayLinkFired(_: CADisplayLink) {
				guard self.demand != .none else { return }
				// this seems to always return .max(0)
				_ = self.subscriber.receive(self.link.targetTimestamp)
			}
			
		#else
			@objc private func timerFired() {
				guard self.demand != .none else { return }
				// this seems to always return .max(0)
				_ = self.subscriber.receive(CACurrentMediaTime())
			}
		#endif
	}
	
	public var preferredFramesPerSecond: Int
	
	public init(preferredFramesPerSecond: Int = 0) {
		self.preferredFramesPerSecond = preferredFramesPerSecond
	}
	
	public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, CFTimeInterval == S.Input {
		let subscription = Subscription(subscriber: subscriber, preferredFramesPerSecond: self.preferredFramesPerSecond)
		
		subscriber.receive(subscription: subscription)
	}
	
	public typealias Output = CFTimeInterval
	
	public typealias Failure = Never
}
