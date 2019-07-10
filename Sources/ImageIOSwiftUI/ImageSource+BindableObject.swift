import Combine
import ImageIOSwift
import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ImageSource: BindableObject {
    public var didChange: Publishers.ReceiveOn<NotificationCenter.Publisher, RunLoop> {
        return NotificationCenter.default.publisher(for: ImageSource.didUpdateData, object: self)
            .receive(on: RunLoop.main)
    }
}
