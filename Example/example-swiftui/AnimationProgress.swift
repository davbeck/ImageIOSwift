import SwiftUI

struct AnimationProgress: View {
	var progress: Double

	var body: some View {
		GeometryReader { proxy in
			HStack {
				Rectangle()
					.fill(Color.blue.opacity(0.5))
					.frame(width: proxy.size.width * CGFloat(self.progress))
					.fixedSize(horizontal: true, vertical: false)
				Spacer()
			}
		}
		.frame(height: 10)
	}
}
