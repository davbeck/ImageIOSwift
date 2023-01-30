import ImageIO

public extension ImageProperties {
	struct TIFFProperties {
		public let rawValue: [CFString: Any]

		public init(rawValue: [CFString: Any]) {
			self.rawValue = rawValue
		}

		public var orientation: Int? {
			self.rawValue[kCGImagePropertyTIFFOrientation] as? Int
		}

		public var xResolution: Int? {
			self.rawValue[kCGImagePropertyTIFFXResolution] as? Int
		}

		public var yResolution: Int? {
			self.rawValue[kCGImagePropertyTIFFYResolution] as? Int
		}
	}

	var tiff: TIFFProperties? {
		guard let rawValue = self.rawValue[kCGImagePropertyTIFFDictionary] as? [CFString: Any] else { return nil }

		return TIFFProperties(rawValue: rawValue)
	}
}
