import ImageIO

extension ImageProperties {
    public struct TIFFProperties {
        public let rawValue: [CFString: Any]
        
        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
        }
        
        public var orientation: Int? {
            return self.rawValue[kCGImagePropertyTIFFOrientation] as? Int
        }
        
        public var xResolution: Int? {
            return self.rawValue[kCGImagePropertyTIFFXResolution] as? Int
        }
        
        public var yResolution: Int? {
            return self.rawValue[kCGImagePropertyTIFFYResolution] as? Int
        }
    }
    
    public var tiff: TIFFProperties? {
        guard let rawValue = self.rawValue[kCGImagePropertyTIFFDictionary] as? [CFString: Any] else { return nil }
        
        return TIFFProperties(rawValue: rawValue)
    }
}
