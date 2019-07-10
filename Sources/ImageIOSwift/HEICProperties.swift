import ImageIO

@available(iOS 13.0, *)
extension ImageProperties {
    public struct HEICProperties {
        public let rawValue: [CFString: Any]
        
        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
        }
        
        public var loopCount: Int {
            return self.rawValue[kCGImagePropertyHEICSLoopCount] as? Int ?? 1
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
            return self.unclampedDelayTime ?? self.clampedDelayTime
        }
    }
    
    public var heic: HEICProperties? {
        guard let rawValue = self.rawValue[kCGImagePropertyHEICSDictionary] as? [CFString: Any] else { return nil }
        return HEICProperties(rawValue: rawValue)
    }
}
