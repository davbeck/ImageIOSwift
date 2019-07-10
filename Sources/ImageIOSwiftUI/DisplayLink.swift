import Combine
import Foundation
import QuartzCore

public struct DisplayLink: Publisher {
    class Subscription<S>: Combine.Subscription where S: Subscriber, Never == S.Failure, CFTimeInterval == S.Input {
        //		#if os(iOS)
        //		private lazy var link = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        //		#endif
        private var timer: Timer?
        private let subscriber: AnySubscriber<CFTimeInterval, Never>
        
        private var demand: Subscribers.Demand = .unlimited {
            didSet {
                //				#if os(iOS)
                //				link.isPaused = demand == .none
                //				#endif
            }
        }
        
        fileprivate init(subscriber: S, preferredFramesPerSecond: Int) {
            self.subscriber = AnySubscriber(subscriber)
            //			#if os(iOS)
            //			link.preferredFramesPerSecond = preferredFramesPerSecond
            //			link.add(to: .main, forMode: .default)
            //			#endif
            
            let timeInterval = preferredFramesPerSecond == 0 ? 1 / 60 : 1 / TimeInterval(preferredFramesPerSecond)
            self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        }
        
        deinit {
            //			#if os(iOS)
            //			link.invalidate()
            //			#endif
            timer?.invalidate()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.demand = demand
        }
        
        func cancel() {
            self.demand = .none
        }
        
        //		#if os(iOS)
        //		@objc private func displayLinkFired(_ link: CADisplayLink) {
        //			guard demand != .none else { return }
        //			// this seems to always return .max(0)
        //			_ = subscriber.receive(self.link.targetTimestamp)
        //		}
        //		#endif
        @objc private func timerFired() {
            guard self.demand != .none else { return }
            // this seems to always return .max(0)
            _ = self.subscriber.receive(CACurrentMediaTime())
        }
    }
    
    public var preferredFramesPerSecond: Int = 0
    
    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, CFTimeInterval == S.Input {
        let subscription = Subscription(subscriber: subscriber, preferredFramesPerSecond: self.preferredFramesPerSecond)
        
        subscriber.receive(subscription: subscription)
    }
    
    public typealias Output = CFTimeInterval
    
    public typealias Failure = Never
    
    public init() {}
}
