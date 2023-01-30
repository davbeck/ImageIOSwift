import ImageIO

@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public extension ImageProperties {
	struct HEICProperties {
		public let rawValue: [CFString: Any]

		public init(rawValue: [CFString: Any]) {
			self.rawValue = rawValue
		}

		public var loopCount: Int {
			self.rawValue[kCGImagePropertyHEICSLoopCount] as? Int ?? 1
		}

		public var clampedDelayTime: Double? {
			guard
				let delay = rawValue[kCGImagePropertyHEICSDelayTime] as? Double,
				delay > 0
			else { return nil }
			return delay
		}

		public var unclampedDelayTime: Double? {
			guard
				let delay = rawValue[kCGImagePropertyHEICSUnclampedDelayTime] as? Double,
				delay > 0
			else { return nil }
			return delay
		}

		public var delayTime: Double? {
			self.unclampedDelayTime ?? self.clampedDelayTime
		}
	}

	var heic: HEICProperties? {
		guard let rawValue = self.rawValue[kCGImagePropertyHEICSDictionary] as? [CFString: Any] else { return nil }
		return HEICProperties(rawValue: rawValue)
	}
}
