import Foundation
import ImageIO

public struct ImageProperties {
	public let rawValue: [CFString: Any]
	
	public init(rawValue: [CFString: Any]) {
		self.rawValue = rawValue
	}
	
	// MARK: - Top level
	
	public var fileSize: Int? {
		return self.rawValue[kCGImagePropertyFileSize] as? Int
	}
	
	public var pixelWidth: CGFloat? {
		return self.rawValue[kCGImagePropertyPixelWidth] as? CGFloat
	}
	
	public var pixelHeight: CGFloat? {
		return self.rawValue[kCGImagePropertyPixelHeight] as? CGFloat
	}
	
	public var imageSize: CGSize? {
		guard var width = pixelWidth, var height = pixelHeight else { return nil }
		
		switch self.exifOrientation {
		case 5...8: // http://magnushoff.com/jpeg-orientation.html
			swap(&width, &height)
		default: break
		}
		
		return CGSize(width: width, height: height)
	}
	
	public var exifOrientation: Int {
		return self.rawValue[kCGImagePropertyOrientation] as? Int ?? tiff?.orientation ?? iptc?.orientation ?? 1
	}
	
	public var transform: CGAffineTransform {
		switch self.exifOrientation {
		case 2:
			return CGAffineTransform(scaleX: -1, y: 1)
		case 3:
			return CGAffineTransform(scaleX: -1, y: -1)
		case 4:
			return CGAffineTransform(scaleX: 1, y: -1)
		case 5:
			return CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2)
		case 6:
			return CGAffineTransform(rotationAngle: .pi / 2)
		case 7:
			return CGAffineTransform(scaleX: -1, y: 1).rotated(by: -.pi / 2)
		case 8:
			return CGAffineTransform(rotationAngle: -.pi / 2)
		default: // 1
			return CGAffineTransform.identity
		}
	}
	
	// MARK: - Aggregate
	
	public var loopCount: Int {
		if #available(iOS 13.0, *) {
			return heic?.loopCount ?? gif?.loopCount ?? png?.loopCount ?? 1
		} else {
			return gif?.loopCount ?? png?.loopCount ?? 1
		}
	}
	
	public var clampedDelayTime: Double? {
		if #available(iOS 13.0, *) {
			return heic?.clampedDelayTime ?? gif?.clampedDelayTime ?? png?.clampedDelayTime
		} else {
			return gif?.clampedDelayTime ?? png?.clampedDelayTime
		}
	}
	
	public var unclampedDelayTime: Double? {
		if #available(iOS 13.0, *) {
			return heic?.unclampedDelayTime ?? gif?.unclampedDelayTime ?? png?.unclampedDelayTime
		} else {
			return gif?.unclampedDelayTime ?? png?.unclampedDelayTime
		}
	}
	
	public var delayTime: Double? {
		return self.unclampedDelayTime ?? self.clampedDelayTime
	}
}

extension ImageSource {
	public var totalDuration: Double {
		return (0..<count).reduce(0) { $0 + (self.properties(at: $1).delayTime ?? 0) }
	}
	
	public var preferredFramesPerSecond: Int {
		guard let shortestDelayTime = (0..<count).map({ (self.properties(at: $0).delayTime ?? 0) }).min() else { return 1 }
		return Int(ceil(1 / shortestDelayTime))
	}
	
	public func animationFrame(at timestamp: TimeInterval) -> Int {
		guard self.count > 1, !self.totalDuration.isZero else { return 0 }
		
		let loopCount = self.properties().loopCount
		let previousLoops = floor(timestamp / self.totalDuration)
		if loopCount != 0, Int(previousLoops) >= loopCount {
			return self.count - 1
		}
		
		let normalizedTimestamp = timestamp - (previousLoops * self.totalDuration)
		
		var offset: TimeInterval = 0
		var frame: Int = 0
		while frame < count {
			let delay = self.properties(at: frame).delayTime ?? 0
			if offset + delay >= normalizedTimestamp {
				return frame
			}
			
			offset += delay
			frame += 1
		}
		
		return frame
	}
}
