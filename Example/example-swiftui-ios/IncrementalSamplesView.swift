import ImageIOSwiftUI
import SwiftUI

private let samples = Sample.images.filter { !$0.url.isFileURL }

struct IncrementalSamplesView: View {
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
	struct IncrementalSamplesView_Previews: PreviewProvider {
		static var previews: some View {
			IncrementalSamplesView()
		}
	}
#endif
