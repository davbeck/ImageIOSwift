import ImageIOSwift
import UIKit

extension ImageSourceController {
	public var currentUIImage: UIImage? {
		guard let cgImage = currentImage else { return nil }
		
		let orientation = currentProperties.orientation
		return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
	}
}
