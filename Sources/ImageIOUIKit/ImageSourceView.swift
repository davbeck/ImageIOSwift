#if canImport(UIKit)
	import ImageIOSwift
	import UIKit

	public protocol ImageSourceViewDelegate: AnyObject {
		func imageSourceViewDidUpdate(_ imageSourceView: ImageSourceView)
	}

	open class ImageSourceView: UIView {
		public weak var delegate: ImageSourceViewDelegate?

		public var thumbnailOptions: ImageSourceController.ThumbnailOptions? {
			didSet {
				self.controller?.thumbnailOptions = self.thumbnailOptions
			}
		}

		private var controller: ImageSourceController? {
			didSet {
				oldValue?.stopAnimating()
				oldValue?.delegate = nil

				self.controller?.delegate = self

				self.update()

				if window != nil, self.isAnimationEnabled {
					self.controller?.startAnimating()
				}
			}
		}

		private var _imageSource: ImageSource? {
			get {
				controller?.imageSource
			}
			set {
				guard controller?.imageSource !== newValue else { return }
				if let newValue = newValue {
					controller = ImageSourceController(imageSource: newValue, thumbnailOptions: thumbnailOptions)
				} else {
					controller = nil
				}
			}
		}

		open var imageSource: ImageSource? {
			get {
				self._imageSource
			}
			set {
				guard self.controller?.imageSource !== newValue else { return }
				self._imageSource = newValue
				self.task = nil
			}
		}

		public var displayedImage: UIImage? {
			self.controller?.currentUIImage
		}

		fileprivate func update() {
			self.displayView.layer.contents = self.controller?.currentImage
			self.displayView.transform = self.controller?.currentProperties.transform ?? CGAffineTransform.identity
			self.invalidateIntrinsicContentSize()

			self.delegate?.imageSourceViewDidUpdate(self)
		}

		// MARK: - URL Loading

		public var task: ImageSourceDownloader.Task? {
			didSet {
				guard task !== oldValue else { return }
				oldValue?.cancel()

				_imageSource = task?.imageSource
			}
		}

		open func load(_ url: URL, with downloader: ImageSourceDownloader = .shared, completionHandler: ((ImageSource?, Data?, URLResponse?, Error?) -> Void)? = nil) {
			if url.isFileURL {
				self.imageSource = ImageSource(url: url)
			} else {
				self.task = downloader.download(url, completionHandler: completionHandler)
			}
		}

		// MARK: - Initialization

		/// Used to display the current CGImage
		///
		/// While you could set the CGImage directly on the view's primary layer, any transformations done to the view would interfere with the transformations set for the images orientation.
		private let displayView = UIView()

		private func commonInit() {
			self.addSubview(self.displayView)
		}

		override public init(frame: CGRect) {
			super.init(frame: frame)

			self.commonInit()
		}

		public required init?(coder: NSCoder) {
			super.init(coder: coder)

			self.commonInit()
		}

		deinit {
			controller?.stopAnimating()
			task?.cancel()
		}

		override open func didMoveToWindow() {
			super.didMoveToWindow()

			if window != nil, self.isAnimationEnabled {
				self.controller?.startAnimating()
			} else {
				self.controller?.stopAnimating()
			}
		}

		// MARK: - Layout

		override open func layoutSubviews() {
			super.layoutSubviews()

			self.displayView.frame = bounds
		}

		override open var intrinsicContentSize: CGSize {
			controller?.currentProperties.imageSize ??
				CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
		}

		override open var contentMode: UIView.ContentMode {
			didSet {
				self.displayView.contentMode = self.contentMode
			}
		}

		// MARK: - Animation

		public var isAnimationEnabled: Bool = false {
			didSet {
				guard self.isAnimationEnabled != oldValue else { return }

				if window != nil, self.isAnimationEnabled {
					self.controller?.startAnimating()
				} else {
					self.controller?.stopAnimating()
				}
			}
		}
	}

	extension ImageSourceView: ImageSourceControllerDelegate {
		public func imageSourceControllerDidUpdate(_: ImageSourceController) {
			self.update()
		}
	}
#endif
