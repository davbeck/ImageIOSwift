import ImageIOSwift
import SwiftUI

public typealias ImageSourceViewContent<Content: View> = (_ imageSource: ImageSource, _ animationFrame: Int, _ label: Text) -> Content
let defaultImageSourceContent = {
	StaticImageSourceView(imageSource: $0, animationFrame: $1, label: $2)
}

public struct ImageSourceView<Content: View>: View {
	@ObjectBinding public var imageSource: ImageSource
	public var isAnimationEnabled: Bool = true
	public var label: Text
	public var content: ImageSourceViewContent<Content>
	
	public init(imageSource: ImageSource, isAnimationEnabled: Bool = true, label: Text, content: @escaping ImageSourceViewContent<Content>) {
		self.imageSource = imageSource
		self.isAnimationEnabled = isAnimationEnabled
		self.label = label
		self.content = content
	}
	
	public var body: some View {
		if isAnimationEnabled, imageSource.status == .complete, imageSource.count > 1 {
			return AnyView(AnimatedImageSourceView(imageSource: imageSource, label: label, content: content))
		} else {
			return AnyView(self.content(imageSource, 0, label))
		}
	}
}

extension ImageSourceView where Content == StaticImageSourceView {
	public init(imageSource: ImageSource, isAnimationEnabled: Bool = true, label: Text) {
		self.init(
			imageSource: imageSource,
			isAnimationEnabled: isAnimationEnabled,
			label: label,
			content: defaultImageSourceContent
		)
	}
}
