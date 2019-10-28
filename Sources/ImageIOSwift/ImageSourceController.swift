import Foundation
import CoreGraphics

public protocol ImageSourceControllerDelegate: AnyObject {
	func imageSourceControllerWillUpdate(_ imageSourceController: ImageSourceController)
	func imageSourceControllerDidUpdate(_ imageSourceController: ImageSourceController)
}

extension ImageSourceControllerDelegate {
	public func imageSourceControllerWillUpdate(_: ImageSourceController) {}
	public func imageSourceControllerDidUpdate(_: ImageSourceController) {}
}

/// Manages the display of an image source, including incremental loading and animation.
///
/// This controller will handle updates from an image source and animation timing. It renders each frame on a background queue and then synchronizes with the main queue. You should use this only from the main queue.
public class ImageSourceController {
	public weak var delegate: ImageSourceControllerDelegate?
	
	/// The currently displayed frame of animation.
	public private(set) var currentFrame: Int = 0 {
		didSet {
			guard self.currentFrame != oldValue else { return }
			self.setNeedsUpdate()
		}
	}
	
	/// The current image that should be rendered.
	public private(set) var currentImage: CGImage?
	/// Properties for the current image.
	///
	/// You can use this to get things like the images size and orientation.
	public private(set) var currentProperties: ImageProperties = ImageProperties()
	
	/// The image source that is managed.
	public let imageSource: ImageSource
	
	private var displayLink: DisplayLink? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	/// Create a controller and track the image source.
	/// - Parameter imageSource: The image source to manage.
	public init(imageSource: ImageSource) {
		self.imageSource = imageSource
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.didUpdateData), name: ImageSource.didUpdateData, object: imageSource)
		
		self.setNeedsUpdate()
	}
	
	deinit {
		displayLink?.invalidate()
		NotificationCenter.default.removeObserver(self)
	}
	
	private var imageCache = NSCache<NSNumber, CGImage>()
	private func image(at frame: Int) -> CGImage? {
		var options = ImageSource.ImageOptions()
		options.shouldDecodeImmediately = true
		
		if let image = imageCache.object(forKey: NSNumber(value: frame)) {
			return image
		} else if let image = self.imageSource.cgImage(at: frame, options: options) {
			if self.imageSource.status == .complete {
				self.imageCache.setObject(image, forKey: NSNumber(value: frame))
			}
			return image
		} else {
			return nil
		}
	}
	
	private var isUpdating = false
	private func setNeedsUpdate() {
		if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
			dispatchPrecondition(condition: .onQueue(.main))
		}
		
		guard !self.isUpdating else {
			return
		}
		self.isUpdating = true
		
		let updateIteration = self.updateIteration
		let currentFrame = self.currentFrame
		
		DispatchQueue.global().async {
			let image = self.image(at: currentFrame)
			let properties = self.imageSource.properties(at: currentFrame)
			
			DispatchQueue.main.async {
				self.sendWillUpdate()
				
				self.currentImage = image
				self.currentProperties = properties
				
				self.sendDidUpdate()
				
				// if something changed while we were updating, update again
				self.isUpdating = false
				if self.updateIteration != updateIteration || self.currentFrame != currentFrame {
					self.setNeedsUpdate()
				}
			}
		}
	}
	
	fileprivate func sendWillUpdate() {
		self.delegate?.imageSourceControllerWillUpdate(self)
	}
	
	fileprivate func sendDidUpdate() {
		self.delegate?.imageSourceControllerDidUpdate(self)
	}
	
	// MARK: - Animation
	
	private var wantsAnimation: Bool = false
	/// When the image source is actively being managed, this will be true.
	///
	/// When you call `startAnimating`, the animation might not start immediately because the image is still being downloaded. This will only be true when the image is fully downloaded and animation has actually begun.
	public private(set) var isAnimating: Bool = false
	
	/// Start animating the image.
	///
	/// Animation will not start until the image has fully downloaded. You should call this method when a view is displayed.
	public func startAnimating() {
		guard self.imageSource.status == .complete else {
			self.wantsAnimation = true
			return
		}
		guard
			self.imageSource.count > 1,
			self.imageSource.totalDuration > 0
		else { return }
		
		self.wantsAnimation = false
		self.isAnimating = true
		
		let animationStartTime = DisplayLink.currentTime
		self.displayLink = DisplayLink(preferredFramesPerSecond: self.imageSource.preferredFramesPerSecond) { [weak self] timestamp in
			guard let self = self else { return }
			let frame = self.imageSource.animationFrame(at: timestamp - animationStartTime)
			self.currentFrame = frame
		}
		self.displayLink?.start()
	}
	
	/// Stop animating and reset.
	///
	/// This does not pause the animation, instead it stops animation, leaving it on the current frame, but when animation starts again the animation will start from the beginning.
	public func stopAnimating() {
		self.displayLink = nil
		
		self.isAnimating = false
	}
	
	// MARK: - Notifications
	
	private var updateIteration: Int = 0 {
		didSet {
			self.setNeedsUpdate()
		}
	}
	
	@objc private func didUpdateData(_: Notification) {
		DispatchQueue.main.async {
			self.updateIteration += 1
			
			if self.wantsAnimation, self.imageSource.status == .complete {
				self.startAnimating()
			}
		}
	}
}

#if canImport(Combine)
	import Combine
	
	/// Manages the display of an image source, including incremental loading and animation.
	///
	/// This controller will handle updates from an image source and animation timing. It renders each frame on a background queue and then synchronizes with the main queue. You should use this only from the main queue.
	@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	public class BindableImageSourceController: ImageSourceController, ObservableObject {
		private let _willChange = PassthroughSubject<Void, Never>()
		public var objectWillChange: AnyPublisher<Void, Never>
		
		private let _didChange = PassthroughSubject<Void, Never>()
		public let objectDidChange: AnyPublisher<Void, Never>
		
		public override init(imageSource: ImageSource) {
			self.objectWillChange = self._willChange.eraseToAnyPublisher()
			self.objectDidChange = self._didChange.eraseToAnyPublisher()
			
			super.init(imageSource: imageSource)
		}
		
		override func sendWillUpdate() {
			super.sendWillUpdate()
			
			self._willChange.send()
		}
		
		override func sendDidUpdate() {
			super.sendDidUpdate()
			
			self._didChange.send()
		}
	}
#endif
