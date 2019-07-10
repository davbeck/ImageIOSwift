import ImageIO

extension ImageProperties {
    public struct PNGProperties {
        public let rawValue: [CFString: Any]
        
        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
        }
        
        public var loopCount: Int {
            return self.rawValue[kCGImagePropertyAPNGLoopCount] as? Int ?? 1
        }
        
        public var clampedDelayTime: Double? {
            guard
                let delay = rawValue[kCGImagePropertyAPNGDelayTime] as? Double,
                delay > 0
            else { return nil }
            return delay
        }
        
        public var unclampedDelayTime: Double? {
            guard
                let delay = rawValue[kCGImagePropertyAPNGUnclampedDelayTime] as? Double,
                delay > 0
            else { return nil }
            return delay
        }
        
        public var delayTime: Double? {
            return self.unclampedDelayTime ?? self.clampedDelayTime
        }
    }
    
    public var png: PNGProperties? {
        guard let rawValue = self.rawValue[kCGImagePropertyPNGDictionary] as? [CFString: Any] else { return nil }
        
        return PNGProperties(rawValue: rawValue)
    }
}
