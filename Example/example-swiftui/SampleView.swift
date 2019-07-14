import ImageIOSwiftUI
import SwiftUI

struct SampleView: View {
	var sample: Sample
	var isAnimationEnabled: Bool = true
	
	var body: some View {
		VStack {
			URLImageSourceView(
				url: sample.url,
				isAnimationEnabled: isAnimationEnabled,
				label: Text(sample.name)
			) { imageSource, animationFrame, label in
				StaticImageSourceView(imageSource: imageSource, animationFrame: animationFrame, label: label)
					.aspectRatio(contentMode: .fit)
					.overlay(
						Rectangle()
							.fill(Color.blue.opacity(0.5))
							.frame(height: 10)
							.relativeWidth(Length(imageSource.progress(atFrame: animationFrame))),
						alignment: .bottomLeading
					)
			}
		}
		.padding()
		.navigationBarTitle(Text(sample.name), displayMode: .inline)
	}
}

#if DEBUG
	struct SampleView_Previews: PreviewProvider {
		static var previews: some View {
			SampleView(sample: Sample.images[0])
		}
	}
#endif
