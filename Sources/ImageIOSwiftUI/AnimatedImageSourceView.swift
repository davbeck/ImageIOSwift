import ImageIOSwift
import SwiftUI

struct AnimatedImageSourceView<Content: View>: View {
	@ObjectBinding var imageSource: ImageSource
	var label: Text
	var content: ImageSourceViewContent<Content>
	
	@State var startTimestamp: TimeInterval? = .none
	@State var animationFrame: Int = 0
	
	var displayLink: DisplayLink {
		DisplayLink(preferredFramesPerSecond: self.imageSource.preferredFramesPerSecond)
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
