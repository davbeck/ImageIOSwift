import Combine
import ImageIOSwift
import SwiftUI

public struct ImageSourceDownloaderKey: EnvironmentKey {
	public static var defaultValue: ImageSourceDownloader { return .shared }
}

extension EnvironmentValues {
	/// Controls the image source downloader that is used to download image sources.
	public var imageSourceDownloader: ImageSourceDownloader {
		get { return self[ImageSourceDownloaderKey.self] }
		set { self[ImageSourceDownloaderKey.self] = newValue }
	}
}

/// A view that handles downloading an image source.
///
/// Use this to customize how you display an image task. For instance, you can display a download progress indicator alongside the image.
public struct ImageTaskView<Content: View>: View {
	@Environment(\.imageSourceDownloader) private var imageSourceDownloader: ImageSourceDownloader
	
	/// The request to use to download.
	///
	/// This can be any url that URLSession supports, including file urls.
	public var urlRequest: URLRequest
	/// The custom contents to render the task.
	public var content: (ImageSourceDownloader.Task) -> Content
	
	/// Create an image task view.
	/// - Parameter url: The url to download from.
	/// - Parameter content: The custom contents to render the task.
	public init(_ url: URL, content: @escaping (ImageSourceDownloader.Task) -> Content) {
		self.init(URLRequest(url: url), content: content)
	}
	
	/// Create an image task view.
	/// - Parameter urlRequest: The request to use to download.
	/// - Parameter content: The custom contents to render the task.
	public init(_ urlRequest: URLRequest, content: @escaping (ImageSourceDownloader.Task) -> Content) {
		self.urlRequest = urlRequest
		self.content = content
	}
	
	public var body: some View {
		return Derived(
			from: urlRequest,
			using: { self.imageSourceDownloader.task(for: $0) }
		) { task in
			self.content(task)
				.onAppear {
					task.resume()
				}
		}
	}
}

/// Displays an image soruce downloaded from a url.
public struct URLImageSourceView: View {
	/// The request to use to download.
	///
	/// This can be any url that URLSession supports, including file urls.
	public var urlRequest: URLRequest
	/// When true, the image source will start animating after it has been downloaded.
	public var isAnimationEnabled: Bool = true
	/// The label associated with the image. The label is used for things like accessibility.
	public var label: Text
	
	/// Create a url image source view.
	///
	/// 	The url will be used for the image label.
	///
	/// - Parameter url: The url to download from.
	/// - Parameter isAnimationEnabled: When true, the image source will start animating after it has been downloaded.
	public init(_ url: URL, isAnimationEnabled: Bool = true) {
		self.init(url, isAnimationEnabled: isAnimationEnabled, label: Text(url.absoluteString))
	}
	
	/// Create a url image source view.
	/// - Parameter url: The url to download from.
	/// - Parameter isAnimationEnabled: When true, the image source will start animating after it has been downloaded.
	/// - Parameter label: The label associated with the image. The label is used for things like accessibility.
	public init(_ url: URL, isAnimationEnabled: Bool = true, label: Text) {
		self.init(URLRequest(url: url), isAnimationEnabled: isAnimationEnabled, label: label)
	}
	
	/// Create a url image source view.
	/// - Parameter urlRequest: The request to use to download.
	/// - Parameter isAnimationEnabled: When true, the image source will start animating after it has been downloaded.
	/// - Parameter label: The label associated with the image. The label is used for things like accessibility.
	public init(_ urlRequest: URLRequest, isAnimationEnabled: Bool = true, label: Text) {
		self.urlRequest = urlRequest
		self.isAnimationEnabled = isAnimationEnabled
		self.label = label
	}
	
	public var body: some View {
		ImageTaskView(self.urlRequest) { task in
			ImageSourceView(
				imageSource: task.imageSource,
				isAnimationEnabled: self.isAnimationEnabled,
				label: self.label
			)
		}
	}
}
