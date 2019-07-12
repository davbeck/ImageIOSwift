import ImageIOSwift
import SwiftUI

struct AnimatedImageSourceView: View {
	@ObjectBinding var imageSource: ImageSource
	var displayLink: DisplayLink
	@State var startTimestamp: TimeInterval? = .none
	@State var animationFrame: Int = 0
	var label: Text
	
	init(imageSource: ImageSource, label: Text) {
		self.imageSource = imageSource
		self.label = label
		self.displayLink = DisplayLink(preferredFramesPerSecond: imageSource.preferredFramesPerSecond)
	}
	
	var body: some View {
		return StaticImageSourceView(imageSource: imageSource, animationFrame: self.animationFrame, label: label)
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
