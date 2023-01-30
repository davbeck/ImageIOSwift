import ImageIOSwift
import UIKit

class MetricsViewController: ImageSourceViewController {
	lazy var sourceTimeLabel = UILabel()
	lazy var sizeTimeLabel = UILabel()
	lazy var imageTimeLabel = UILabel()
	lazy var thumbnailTimeLabel = UILabel()
	lazy var drawThumbnailTimeLabel = UILabel()
	lazy var drawTimeLabel = UILabel()
	lazy var uiImageTimeLabel = UILabel()

	override func viewDidLoad() {
		self.sourceTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: self.sourceTimeLabel, name: "Create Source")
		self.sizeTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: self.sizeTimeLabel, name: "Get Size")
		self.thumbnailTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: self.thumbnailTimeLabel, name: "Create Thumbnail")
		self.drawThumbnailTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: self.drawThumbnailTimeLabel, name: "Draw Thumbnail")
		self.imageTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: self.imageTimeLabel, name: "Create Image")
		self.drawTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: self.drawTimeLabel, name: "Draw Image")
		self.uiImageTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: self.uiImageTimeLabel, name: "UIImage")

		super.viewDidLoad()
	}

	override func loadImageSource() {
		// TODO: add http based incremental load handling

		var start = Date()
		let imageSource = ImageSource(url: url)
		let createSourceDuration = -start.timeIntervalSinceNow

		start = Date()
		guard let size = imageSource?.properties(at: 0).imageSize else { return }
		let sizeDuration = -start.timeIntervalSinceNow

		start = Date()
		var options = ImageSource.ImageOptions()
		options.thumbnailMaxPixelSize = 500
		let thumbnail = imageSource?.cgThumbnailImage(at: 0, options: options)
		let createThumbnailDuration = -start.timeIntervalSinceNow

		if let thumbnail = thumbnail {
			UIGraphicsBeginImageContextWithOptions(thumbnail.size, true, 1)
			start = Date()
			UIGraphicsGetCurrentContext()?.draw(thumbnail, in: CGRect(origin: .zero, size: thumbnail.size))
			let drawThumbnailDuration = -start.timeIntervalSinceNow
			UIGraphicsEndImageContext()

			self.thumbnailTimeLabel.text = "\(String(format: "%.4f", createThumbnailDuration))s (\(thumbnail.width)x\(thumbnail.height))"
			self.drawThumbnailTimeLabel.text = "\(String(format: "%.4f", drawThumbnailDuration))s"
		} else {
			self.thumbnailTimeLabel.text = "\(String(format: "%.4f", createThumbnailDuration))s (missing)"
			self.drawThumbnailTimeLabel.text = nil
		}

		start = Date()
		guard let image = imageSource?.cgImage(at: 0) else { return }
		let createImageDuration = -start.timeIntervalSinceNow

		start = Date()
		_ = imageSource?.cgImage(at: 0)
		let secondCreateImageDuration = -start.timeIntervalSinceNow

		UIGraphicsBeginImageContextWithOptions(size, true, 1)
		start = Date()
		UIGraphicsGetCurrentContext()?.draw(image, in: CGRect(origin: .zero, size: size))
		let drawDuration = -start.timeIntervalSinceNow
		UIGraphicsEndImageContext()

		UIGraphicsBeginImageContextWithOptions(size, true, 1)
		start = Date()
		UIGraphicsGetCurrentContext()?.draw(image, in: CGRect(origin: .zero, size: size))
		let secondDrawDuration = -start.timeIntervalSinceNow
		UIGraphicsEndImageContext()

		UIGraphicsBeginImageContextWithOptions(size, true, 1)
		start = Date()
		UIImage(contentsOfFile: url.path)?.draw(in: CGRect(origin: .zero, size: size))
		let uiImageDrawTime = -start.timeIntervalSinceNow
		UIGraphicsEndImageContext()

		self.sourceTimeLabel.text = "\(String(format: "%.4f", createSourceDuration))s"
		self.sizeTimeLabel.text = "\(String(format: "%.4f", sizeDuration))s"
		self.imageTimeLabel.text = "\(String(format: "%.4f", createImageDuration))s, \(String(format: "%.4f", secondCreateImageDuration))s"
		self.drawTimeLabel.text = "\(String(format: "%.4f", drawDuration))s, \(String(format: "%.4f", secondDrawDuration))s"
		self.uiImageTimeLabel.text = "\(String(format: "%.4f", uiImageDrawTime))s"

		self.imageSource = imageSource
	}
}
