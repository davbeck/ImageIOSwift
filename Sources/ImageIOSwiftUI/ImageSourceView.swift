#if canImport(SwiftUI) && canImport(Combine)
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
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct ImageControllerView<Content: View>: View {
	/// The image source to dipslay.
	public var imageSource: ImageSource

	/// When true, animation will start once the image is loaded.
	public var isAnimationEnabled: Bool

	public var thumbnailOptions: ImageSourceController.ThumbnailOptions?

	/// The contents to use to render the image source.
	public var content: (ImageSourceController) -> Content

	/// Create an image controller view.
	/// - Parameter imageSource: The image source to dipslay.
	/// - Parameter isAnimationEnabled: When true, animation will start once the image is loaded.
	/// - Parameter thumbnailOptions: Optional thumbnail options to use when generating images.
	/// - Parameter content: The content to render for each frame of the image source.
	public init(
		imageSource: ImageSource,
		isAnimationEnabled: Bool = true,
		thumbnailOptions: ImageSourceController.ThumbnailOptions? = nil,
		@ViewBuilder content: @escaping (ImageSourceController) -> Content
	) {
		self.imageSource = imageSource
		self.isAnimationEnabled = isAnimationEnabled
		self.thumbnailOptions = thumbnailOptions
		self.content = content
	}

	public var body: some View {
		StateContainer(
			controller: ImageSourceController(
				imageSource: imageSource,
				thumbnailOptions: thumbnailOptions
			),
			isAnimationEnabled: isAnimationEnabled,
			content: content
		)
		.id(imageSource)
		.id(thumbnailOptions)
	}

	private struct StateContainer: View {
		@StateObject var controller: ImageSourceController
		var isAnimationEnabled: Bool
		var content: (ImageSourceController) -> Content

		var body: some View {
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
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
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
#endif
