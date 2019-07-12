import ImageIOSwiftUI
import SwiftUI

let images = Sample.images.filter({ $0.categories.contains(.animated) })

struct AnimationsView: View {
	
	var body: some View {
		List(images) { sample in
			NavigationLink(destination: SampleView(sample: sample)) {
				Text(sample.name)
			}
		}
		.navigationBarTitle("Animated Images")
	}
}

#if DEBUG
	struct AnimationsView_Previews: PreviewProvider {
		static var previews: some View {
			AnimationsView()
		}
	}
#endif
