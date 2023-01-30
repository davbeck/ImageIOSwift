import ImageIOSwift
import UIKit

public extension ImageSourceController {
	var currentUIImage: UIImage? {
		guard let cgImage = currentImage else { return nil }

		let orientation = currentProperties.orientation
		return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
	}
}
