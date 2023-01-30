import ImageIOSwift
import UIKit

class ProgressiveLoadViewController: ImageSourceViewController {
	deinit {
		incrementTimer = nil
		task?.cancel()
	}

	// MARK: - View Lifecycle

	lazy var statusLabel = UILabel()

	override func viewDidLoad() {
		self.statusLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		self.add(infoLabel: self.statusLabel, name: "Status")

		super.viewDidLoad()

		imageSourceView.isAnimationEnabled = true

		imageView.removeFromSuperview()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if imageSource?.status != .complete, url.isFileURL {
			self.incrementTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.incrementImage), userInfo: nil, repeats: true)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.incrementTimer = nil
	}

	private var task: ImageSourceDownloader.Task?
	private var progressObserver: NSKeyValueObservation?

	override func loadImageSource() {
		guard url.isFileURL else {
			let task = ImageSourceDownloader.shared.download(url)
			imageSource = task.imageSource
			self.task = task

			if #available(iOS 11.0, *) {
				progressObserver = task.sessionTask.progress.observe(\.fractionCompleted, changeHandler: { [weak self] progress, _ in
					DispatchQueue.main.async {
						let percent = Int(round(progress.fractionCompleted * 100))
						self?.statusLabel.text = "\(task.imageSource.status) (\(percent)%)"
					}
				})
			}

			return
		}

		guard let data = try? Data(contentsOf: url) else {
			print("failed to load image source")
			return
		}
		self.data = data

		imageSource = ImageSource.incremental()

		self.progress = 0
	}

	private var data = Data()

	private var progress: Int = 0

	private var incrementTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}

	@objc func incrementImage() {
		guard let imageSource = imageSourceView.imageSource else { return }

		self.progress += 500
		let chunk = self.data.prefix(self.progress)
		if chunk.count == self.data.count {
			self.incrementTimer = nil
		}

		imageSource.update(Data(chunk), isFinal: chunk.count == self.data.count)

		let percent = Int(round(Double(chunk.count) / Double(self.data.count) * 100))
		self.statusLabel.text = "\(imageSource.status) (\(percent)%)"
	}
}
