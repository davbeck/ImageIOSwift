import ImageIOSwift
import SwiftUI

extension ImageSource: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}

/// A view that displays an image source using BindableImageSourceController.
///
/// Use this when you want to customize the display of an image source, for instance to show animation progress or info about the image.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ImageControllerView<Content: View>: View {
	/// The image source to dipslay.
	public var imageSource: ImageSource
	/// When true, animation will start once the image is loaded.
	public var isAnimationEnabled: Bool
	/// The contents to use to render the image source.
	public var content: (BindableImageSourceController) -> Content
	
	/// Create an image controller view.
	/// - Parameter imageSource: The image source to dipslay.
	/// - Parameter isAnimationEnabled: When true, animation will start once the image is loaded.
	/// - Parameter content: The content to render for each frame of the image source.
	public init(imageSource: ImageSource, isAnimationEnabled: Bool = true, content: @escaping (BindableImageSourceController) -> Content) {
		self.imageSource = imageSource
		self.isAnimationEnabled = isAnimationEnabled
		self.content = content
	}
	
	public var body: some View {
		Derived(
			from: imageSource,
			using: { BindableImageSourceController(imageSource: $0, thumbnailOptions: nil) }
		) { controller in
			self.content(controller)
				.onAppear {
					if self.isAnimationEnabled {
						controller.startAnimating()
					}
				}
				.onDisappear {
					controller.stopAnimating()
				}
		}
	}
}

/// A SwiftUI view that displays an image source, updating as it loads.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ImageSourceView: View {
	/// The image source to dipslay.
	public var imageSource: ImageSource
	/// When true, animation will start once the image is loaded.
	public var isAnimationEnabled: Bool
	/// The label associated with the image. The label is used for things like accessibility.
	public var label: Text
	
	/// Create a image source view.
	/// - Parameter imageSource: The image source to dipslay.
	/// - Parameter isAnimationEnabled: When true, animation will start once the image is loaded.
	/// - Parameter label: The label associated with the image. The label is used for things like accessibility.
	public init(imageSource: ImageSource, isAnimationEnabled: Bool = true, label: Text) {
		self.imageSource = imageSource
		self.isAnimationEnabled = isAnimationEnabled
		self.label = label
	}
	
	public var body: some View {
		ImageControllerView(imageSource: imageSource, isAnimationEnabled: isAnimationEnabled) { controller in
			StaticImageSourceView(
				image: controller.currentImage,
				properties: controller.currentProperties,
				label: self.label
			)
		}
	}
}
