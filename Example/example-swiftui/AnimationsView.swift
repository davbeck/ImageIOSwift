import ImageIOSwiftUI
import SwiftUI

private let samples = Sample.images.filter { $0.categories.contains(.animated) }

struct AnimationsView: View {
	var body: some View {
		List(samples) { sample in
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
