import ImageIOSwift
import ImageIOUIKit
import UIKit

class ImageSourceViewController: UIViewController {
	let url: URL

	var imageSource: ImageSource? {
		didSet {
			if let oldValue = oldValue {
				NotificationCenter.default.removeObserver(self, name: nil, object: oldValue.cgImageSource)
			}

			updateInfo()
			imageSourceView.imageSource = imageSource
			imageView.image = imageSource?.image(at: 0)

			if let newValue = imageSource {
				NotificationCenter.default.addObserver(self, selector: #selector(didUpdateData), name: ImageSource.didUpdateData, object: newValue)
			}
		}
	}

	required init(url: URL) {
		self.url = url

		super.init(nibName: nil, bundle: nil)

		self.title = url.lastPathComponent

		self.automaticallyAdjustsScrollViewInsets = false
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Lifecycle

	lazy var scrollView = UIScrollView()

	lazy var imageSourceView = ImageSourceView()
	lazy var imageView = UIImageView()

	lazy var imagesStackView: UIStackView = .init(arrangedSubviews: [
		self.imageSourceView,
		self.imageView,
	])

	lazy var infoStackView: UIStackView = .init(arrangedSubviews: [
		self.imagesStackView,
	])
	lazy var imageSizeLabel = UILabel()
	lazy var framesLabel = UILabel()
	lazy var propertiesLabel = UILabel()
	lazy var properties0Label = UILabel()

	private var nameLabels: [UILabel] = []

	func add(infoLabel: UIView, name: String) {
		let nameLabel = UILabel()
		nameLabel.text = "\(name):"
		nameLabel.textAlignment = .right
		nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
		nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
		nameLabel.setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)

		let lineView = UIStackView(arrangedSubviews: [
			nameLabel,
			infoLabel,
		])
		lineView.axis = .horizontal
		lineView.spacing = 5
		lineView.alignment = .firstBaseline
		self.infoStackView.addArrangedSubview(lineView)

		if let firstName = nameLabels.first {
			nameLabel.widthAnchor.constraint(equalTo: firstName.widthAnchor).isActive = true
		}
		self.nameLabels.append(nameLabel)
	}

	private func add(label text: String, to view: UIView) {
		let effect = UIBlurEffect(style: .dark)
		let background = UIVisualEffectView(effect: effect)
		background.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(background)

		let vibrancy = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: effect))
		vibrancy.translatesAutoresizingMaskIntoConstraints = false
		background.contentView.addSubview(vibrancy)

		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = text
		label.textAlignment = .center
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		vibrancy.contentView.addSubview(label)

		NSLayoutConstraint.activate([
			background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			background.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			vibrancy.leadingAnchor.constraint(equalTo: background.leadingAnchor),
			vibrancy.trailingAnchor.constraint(equalTo: background.trailingAnchor),
			vibrancy.topAnchor.constraint(equalTo: background.topAnchor),
			vibrancy.bottomAnchor.constraint(equalTo: background.bottomAnchor),

			label.leadingAnchor.constraint(equalTo: background.layoutMarginsGuide.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: background.layoutMarginsGuide.trailingAnchor),
			label.topAnchor.constraint(equalTo: background.layoutMarginsGuide.topAnchor),
			label.bottomAnchor.constraint(equalTo: background.layoutMarginsGuide.bottomAnchor),
		])
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .white

		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.alwaysBounceVertical = true
		view.addSubview(self.scrollView)

		self.imageSourceView.backgroundColor = .lightGray
		self.imageSourceView.contentMode = .scaleAspectFit
		self.add(label: "ImageSourceView", to: self.imageSourceView)

		self.imageView.backgroundColor = .lightGray
		self.imageView.contentMode = .scaleAspectFit
		self.add(label: "UIImageView", to: self.imageView)

		self.imagesStackView.axis = .horizontal
		self.imagesStackView.spacing = 10

		self.infoStackView.translatesAutoresizingMaskIntoConstraints = false
		self.infoStackView.axis = .vertical
		self.infoStackView.spacing = 5
		if #available(iOS 11.0, *) {
			infoStackView.setCustomSpacing(10, after: imagesStackView)
		}
		self.scrollView.addSubview(self.infoStackView)

		NSLayoutConstraint.activate([
			self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			self.scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),

			self.imageSourceView.heightAnchor.constraint(equalTo: self.imageSourceView.widthAnchor),
			self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor),

			self.infoStackView.leadingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.leadingAnchor),
			self.infoStackView.trailingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.trailingAnchor),
		])

		if #available(iOS 11.0, *) {
			NSLayoutConstraint.activate([
				scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

				infoStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 5),
				infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -5),
			])
		} else {
			NSLayoutConstraint.activate([
				self.infoStackView.topAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.topAnchor),
				self.infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.scrollView.layoutMarginsGuide.bottomAnchor),
			])
		}

		self.add(infoLabel: self.imageSizeLabel, name: "Image Size")
		self.add(infoLabel: self.framesLabel, name: "Frames")
		self.propertiesLabel.numberOfLines = 0
		self.add(infoLabel: self.propertiesLabel, name: "Properties")
		self.properties0Label.numberOfLines = 0
		self.add(infoLabel: self.properties0Label, name: "Properties[0]")

		self.loadImageSource()
	}

	func loadImageSource() {
		if self.url.isFileURL {
			self.imageSource = ImageSource(url: self.url)
		} else {
			let task = ImageSourceDownloader.shared.download(self.url)
			self.imageSource = task.imageSource
		}
	}

	@objc func didUpdateData() {
		DispatchQueue.main.async {
			self.updateInfo()
		}
	}

	func updateInfo() {
		if let size = imageSource?.properties(at: 0).imageSize {
			self.imageSizeLabel.text = "\(Int(size.width))x\(Int(size.height))"
		} else {
			self.imageSizeLabel.text = nil
		}

		self.framesLabel.text = self.imageSource?.count.description

		self.propertiesLabel.text = self.imageSource?.properties().rawValue.description
		self.properties0Label.text = self.imageSource?.properties(at: 0).rawValue.description
	}
}
