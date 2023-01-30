#if canImport(UIKit)
	import ImageIOSwift
	import UIKit

	public extension UIImage.Orientation {
		init(exifOrientation: Int) {
			switch exifOrientation {
			case 2:
				self = .upMirrored
			case 3:
				self = .down
			case 4:
				self = .downMirrored
			case 5:
				self = .leftMirrored
			case 6:
				self = .right
			case 7:
				self = .rightMirrored
			case 8:
				self = .left
			default: // 1
				self = .up
			}
		}
	}

	extension ImageProperties {
		var orientation: UIImage.Orientation {
			UIImage.Orientation(exifOrientation: exifOrientation)
		}
	}
#endif
