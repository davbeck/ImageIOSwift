import ImageIOSwiftUI
import SwiftUI

func open(_ url: URL) {
	#if os(iOS)
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	#elseif os(macOS)
		NSWorkspace.shared.open(url)
	#endif
}

private let samples = Sample.images.filter { $0.categories.contains(.orientation) }

struct OrientationsView: View {
	var body: some View {
		// there is a bug where the size doesn't get updated on first load using a ScrollView/VStack
		List {
			VStack {
				Text("""
				The EXIF (exchangeable image file format) standard specifies a set of tags that can be embedded in images (among other things). One of these tags specifies the orientation of the photo, and has 8 possible values which cover every possible combination of rotation and mirroring of an image. This enables you to take a picture with your camera sideways or upside-down (or even inside-out), and stand a reasonable chance of having it display properly on your computer.
				""")
				.lineLimit(nil)
				Button(action: {
					open(URL(string: "https://www.daveperrett.com/articles/2012/07/28/exif-orientation-handling-is-a-ghetto/")!)
				}) {
					Text("More info")
				}
				.padding(.bottom, 50)
			}

			ForEach(samples) { sample in
				URLImageSourceView(sample.url, label: Text(sample.name))
					.aspectRatio(contentMode: .fit)
			}
		}
		.navigationBarTitle(Text("EXIF Orientations"), displayMode: .inline)
	}
}

#if DEBUG
	struct OrientationsView_Previews: PreviewProvider {
		static var previews: some View {
			OrientationsView()
		}
	}
#endif
