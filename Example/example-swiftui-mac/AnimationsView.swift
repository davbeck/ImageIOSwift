import ImageIOSwiftUI
import SwiftUI

struct AnimationsView: View {
	var body: some View {
		VStack {
			Text("GIF")
			HStack {
				URLImageSourceView(url: Bundle.main.url(forResource: "animated.gif", withExtension: nil)!)
					.aspectRatio(contentMode: .fit)
				URLImageSourceView(url: Bundle.main.url(forResource: "transparent.gif", withExtension: nil)!)
					.aspectRatio(contentMode: .fit)
			}
			
			Text("PNG")
			HStack {
				URLImageSourceView(url: Bundle.main.url(forResource: "animated.png", withExtension: nil)!)
					.aspectRatio(contentMode: .fit)
				URLImageSourceView(url: Bundle.main.url(forResource: "transparent.png", withExtension: nil)!)
					.aspectRatio(contentMode: .fit)
			}
			
//			Text("HEIC")
//			HStack {
//				URLImageSourceView(url: Bundle.main.url(forResource: "starfield_animation.heic", withExtension: nil)!)
//					.aspectRatio(contentMode: .fit)
//				URLImageSourceView(url: Bundle.main.url(forResource: "sea1_animation.heic", withExtension: nil)!)
//					.aspectRatio(contentMode: .fit)
//			}
		}
	}
}

#if DEBUG
	struct AnimationsView_Previews: PreviewProvider {
		static var previews: some View {
			AnimationsView()
		}
	}
#endif
