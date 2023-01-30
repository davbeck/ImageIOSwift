import Combine
import ImageIOSwiftUI
import SwiftUI

struct SampleView: View {
	var sample: Sample
	var isAnimationEnabled: Bool = true

	var body: some View {
		VStack {
			ImageTaskView(sample.url) { task in
				ImageControllerView(imageSource: task.imageSource) { controller in
					StaticImageSourceView(
						image: controller.currentImage,
						properties: controller.currentProperties,
						label: Text(self.sample.name)
					)
					.overlay(
						AnimationProgress(progress: controller.imageSource.progress(atFrame: controller.currentFrame)),
						alignment: .bottom
					)
				}
				.overlay(
					DownloadProgress(progress: task.sessionTask.progress),
					alignment: .topTrailing
				)
			}
			.aspectRatio(contentMode: .fit)
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
