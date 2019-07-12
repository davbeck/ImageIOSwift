import Combine
import ImageIOSwift
import SwiftUI

extension ImageSourceDownloader.Task: BindableObject {
	public var didChange: AnyPublisher<Void, Never> {
		return Publishers.Empty(completeImmediately: false).eraseToAnyPublisher()
	}
}

public struct ImageSourceDownloaderKey: EnvironmentKey {
	public static var defaultValue: ImageSourceDownloader { return .shared }
}

extension EnvironmentValues {
	public var imageSourceDownloader: ImageSourceDownloader {
		get { return self[ImageSourceDownloaderKey.self] }
		set { self[ImageSourceDownloaderKey.self] = newValue }
	}
}

struct RemoteImageSourceView: View {
	@State var task: ImageSourceDownloader.Task
	var isAnimationEnabled: Bool = true
	var label: Text
	
	var body: some View {
		return ImageSourceView(
			imageSource: task.imageSource,
			isAnimationEnabled: isAnimationEnabled,
			label: self.label
		)
		.onAppear {
			self.task.resume()
		}
	}
}

public struct URLImageSourceView: View {
	@Environment(\.imageSourceDownloader) private var imageSourceDownloader: ImageSourceDownloader
	
	public var url: URL
	public var isAnimationEnabled: Bool = true
	public var label: Text
	
	public init(url: URL, isAnimationEnabled: Bool = true) {
		self.init(url: url, isAnimationEnabled: isAnimationEnabled, label: Text(url.absoluteString))
	}
	
	public init(url: URL, isAnimationEnabled: Bool = true, label: Text) {
		self.url = url
		self.isAnimationEnabled = isAnimationEnabled
		self.label = label
	}
	
	public var body: some View {
		return RemoteImageSourceView(
			task: self.imageSourceDownloader.task(for: self.url),
			isAnimationEnabled: self.isAnimationEnabled,
			label: self.label
		).id(url)
	}
}
