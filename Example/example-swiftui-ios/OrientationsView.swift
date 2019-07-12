//
//  OrientationsView.swift
//  example-swiftui-ios
//
//  Created by David Beck on 7/12/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import ImageIOSwiftUI

let samples = Sample.images.filter({ $0.categories.contains(.orientation) })

struct OrientationsView : View {
    var body: some View {
		// there is a bug where the size doesn't get updated on first load using a ScrollView/VStack
			List {
				VStack {
					Text("""
					The EXIF (exchangeable image file format) standard specifies a set of tags that can be embedded in images (among other things). One of these tags specifies the orientation of the photo, and has 8 possible values which cover every possible combination of rotation and mirroring of an image. This enables you to take a picture with your camera sideways or upside-down (or even inside-out), and stand a reasonable chance of having it display properly on your computer.
					""")
						.lineLimit(nil)
					Button(action: {
						UIApplication.shared.open(URL(string: "https://www.daveperrett.com/articles/2012/07/28/exif-orientation-handling-is-a-ghetto/")!, options: [:], completionHandler: nil)
					}) {
						Text("More info")
					}
					.padding(.bottom, 50)
				}
				
				ForEach(samples) { sample in
					URLImageSourceView(url: sample.url, label: Text(sample.name))
					.aspectRatio(contentMode: .fit)
				}
			}
			.padding()
		.navigationBarTitle(Text("EXIF Orientations"), displayMode: .inline)
    }
}

#if DEBUG
struct OrientationsView_Previews : PreviewProvider {
    static var previews: some View {
        OrientationsView()
    }
}
#endif
