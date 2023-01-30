import ImageIO

public extension ImageProperties {
	struct IPTCProperties {
		public let rawValue: [CFString: Any]

		public init(rawValue: [CFString: Any]) {
			self.rawValue = rawValue
		}

		public var orientation: Int? {
			self.rawValue[kCGImagePropertyIPTCImageOrientation] as? Int
		}
	}

	var iptc: IPTCProperties? {
		guard let rawValue = self.rawValue[kCGImagePropertyIPTCDictionary] as? [CFString: Any] else { return nil }

		return IPTCProperties(rawValue: rawValue)
	}
}
