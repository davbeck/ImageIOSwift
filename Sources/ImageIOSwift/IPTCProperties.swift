import ImageIO

extension ImageProperties {
    public struct IPTCProperties {
        public let rawValue: [CFString: Any]
        
        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
        }
        
        public var orientation: Int? {
            return self.rawValue[kCGImagePropertyIPTCImageOrientation] as? Int
        }
    }
    
    public var iptc: IPTCProperties? {
        guard let rawValue = self.rawValue[kCGImagePropertyIPTCDictionary] as? [CFString: Any] else { return nil }
        
        return IPTCProperties(rawValue: rawValue)
    }
}
