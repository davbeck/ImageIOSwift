import ImageIO

extension ImageProperties {
	public struct JPEGProperties {
		public let rawValue: [CFString: Any]
		
		public init(rawValue: [CFString: Any]) {
			self.rawValue = rawValue
		}
		
		public var xDensity: CGFloat? {
			return self.rawValue[kCGImagePropertyJFIFXDensity] as? CGFloat
		}
		
		public var yDensity: CGFloat? {
			return self.rawValue[kCGImagePropertyJFIFYDensity] as? CGFloat
		}
		
		public var orientation: Int? {
			return self.rawValue[kCGImagePropertyOrientation] as? Int
		}
	}
	
	public var jpeg: JPEGProperties? {
		guard let rawValue = self.rawValue[kCGImagePropertyJFIFDictionary] as? [CFString: Any] else { return nil }
		
		return JPEGProperties(rawValue: rawValue)
	}
}
