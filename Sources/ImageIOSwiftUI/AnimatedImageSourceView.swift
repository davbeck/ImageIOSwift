import ImageIOSwift
import SwiftUI

struct AnimatedImageSourceView<Content: View>: View {
	@ObjectBinding var imageSource: ImageSource
	var displayLink: DisplayLink
	@State var startTimestamp: TimeInterval? = .none
	@State var animationFrame: Int = 0
	var label: Text
	var content: ImageSourceViewContent<Content>
	
	init(imageSource: ImageSource, label: Text, content: @escaping ImageSourceViewContent<Content>) {
		self.imageSource = imageSource
		self.label = label
		self.displayLink = DisplayLink(preferredFramesPerSecond: imageSource.preferredFramesPerSecond)
		self.content = content
	}
	
	var body: some View {
		return self.content(imageSource, self.animationFrame, label)
			.onAppear {
				self.startTimestamp = CACurrentMediaTime()
			}
			.onReceive(displayLink) { targetTimestamp in
				if let startTimestamp = self.startTimestamp {
					let timestamp = targetTimestamp - startTimestamp
					self.animationFrame = self.imageSource.animationFrame(at: timestamp)
				}
			}
	}
}
