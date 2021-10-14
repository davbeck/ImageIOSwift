import Combine
import ImageIOSwift

/// Manages the display of an image source, including incremental loading and animation.
///
/// This controller will handle updates from an image source and animation timing. It renders each frame on a background queue and then synchronizes with the main queue. You should use this only from the main queue.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class BindableImageSourceController: ImageSourceController, ObservableObject {
	private let _willChange = PassthroughSubject<Void, Never>()
	public var objectWillChange: AnyPublisher<Void, Never>
	
	private let _didChange = PassthroughSubject<Void, Never>()
	public let objectDidChange: AnyPublisher<Void, Never>
	
	public override init(imageSource: ImageSource, thumbnailOptions: ImageSourceController.ThumbnailOptions? = nil) {
		self.objectWillChange = self._willChange.eraseToAnyPublisher()
		self.objectDidChange = self._didChange.eraseToAnyPublisher()
		
		super.init(imageSource: imageSource, thumbnailOptions: thumbnailOptions)
	}
	
	public override func sendWillUpdate() {
		super.sendWillUpdate()
		
		self._willChange.send()
	}
	
	public override func sendDidUpdate() {
		super.sendDidUpdate()
		
		self._didChange.send()
	}
}
