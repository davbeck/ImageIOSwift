import ImageIOSwift
import SwiftUI

public struct ImageSourceView: View {
    @ObjectBinding public var imageSource: ImageSource
    public var isAnimationEnabled: Bool = true
    public var label: Text
    
    public init(imageSource: ImageSource, isAnimationEnabled: Bool = true, label: Text) {
        self.imageSource = imageSource
        self.isAnimationEnabled = isAnimationEnabled
        self.label = label
    }
    
    public var body: some View {
        if isAnimationEnabled, imageSource.status == .complete, imageSource.count > 1 {
            return AnyView(AnimatedImageSourceView(imageSource: imageSource, label: label))
        } else {
            return AnyView(StaticImageSourceView(imageSource: imageSource, label: label))
        }
    }
}
