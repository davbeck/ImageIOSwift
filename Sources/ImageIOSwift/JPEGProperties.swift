import ImageIO

public extension ImageProperties {
	struct JPEGProperties {
		public let rawValue: [CFString: Any]

		public init(rawValue: [CFString: Any]) {
			self.rawValue = rawValue
		}

		public var xDensity: CGFloat? {
			self.rawValue[kCGImagePropertyJFIFXDensity] as? CGFloat
		}

		public var yDensity: CGFloat? {
			self.rawValue[kCGImagePropertyJFIFYDensity] as? CGFloat
		}

		public var orientation: Int? {
			self.rawValue[kCGImagePropertyOrientation] as? Int
		}
	}

	var jpeg: JPEGProperties? {
		guard let rawValue = self.rawValue[kCGImagePropertyJFIFDictionary] as? [CFString: Any] else { return nil }

		return JPEGProperties(rawValue: rawValue)
	}
}
