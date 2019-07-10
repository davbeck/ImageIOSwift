import ImageIOSwift
import SwiftUI

struct AnimatedImageSourceView: View {
    @ObjectBinding var imageSource: ImageSource
    @State var displayLink = DisplayLink()
    @State var startTimestamp: TimeInterval?
    @State var animationFrame: Int = 0
    var label: Text
    
    var body: some View {
        //		displayLink.preferredFramesPerSecond = imageSource.preferredFramesPerSecond
        
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
