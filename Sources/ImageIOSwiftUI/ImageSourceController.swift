import Combine
import Foundation
import ImageIOSwift
import SwiftUI

/// Manages the display of an image source, including incremental loading and animation.
///
/// This controller will handle updates from an image source and animation timing. It renders each frame on a background queue and then synchronizes with the main queue. You should use this only from the main queue.
public class ImageSourceController: BindableObject {
	private let _willChange = PassthroughSubject<Void, Never>()
	public let willChange: AnyPublisher<Void, Never>
	
	private let _didChange = PassthroughSubject<Void, Never>()
	public let didChange: AnyPublisher<Void, Never>
	
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
	
	/// Create a controller and track the image source.
	/// - Parameter imageSource: The image source to manage.
	public init(imageSource: ImageSource) {
		self.imageSource = imageSource
		
		self.willChange = self._willChange.eraseToAnyPublisher()
		self.didChange = self._didChange.eraseToAnyPublisher()
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.didUpdateData), name: ImageSource.didUpdateData, object: imageSource)
		
		self.setNeedsUpdate()
	}
	
	deinit {
		self.animationObserver?.cancel()
		NotificationCenter.default.removeObserver(self)
	}
	
	private var isUpdating = false
	private func setNeedsUpdate() {
		dispatchPrecondition(condition: .onQueue(.main))
		
		guard !self.isUpdating else {
			return
		}
		self.isUpdating = true
		
		let updateIteration = self.updateIteration
		let currentFrame = self.currentFrame
		
		DispatchQueue.global().async {
			let image = self.imageSource.cgImage(at: currentFrame)
			let properties = self.imageSource.properties(at: currentFrame)
			
			DispatchQueue.main.async {
				self._willChange.send()
				
				self.currentImage = image
				self.currentProperties = properties
				
				self._didChange.send()
				
				// if something changed while we were updating, update again
				self.isUpdating = false
				if self.updateIteration != updateIteration || self.currentFrame != currentFrame {
					self.setNeedsUpdate()
				}
			}
		}
	}
	
	// MARK: - Animation
	
	private var animationObserver: Cancellable? {
		didSet {
			oldValue?.cancel()
		}
	}
	
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
		
		self.animationObserver = DisplayLink(preferredFramesPerSecond: self.imageSource.preferredFramesPerSecond)
			.map { [imageSource] in imageSource.animationFrame(at: $0 - animationStartTime) }
			.removeDuplicates()
			// assign(to:on:) retains self causing a memory leak
			.sink(receiveValue: { [weak self] frame in
				self?.currentFrame = frame
			})
	}
	
	/// Stop animating and reset.
	///
	/// This does not pause the animation, instead it stops animation, leaving it on the current frame, but when animation starts again the animation will start from the beginning.
	public func stopAnimating() {
		self.animationObserver = nil
		
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
