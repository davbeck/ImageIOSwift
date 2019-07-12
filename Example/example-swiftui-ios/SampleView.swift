//
//  SampleView.swift
//  example-swiftui-ios
//
//  Created by David Beck on 7/12/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import ImageIOSwiftUI

struct SampleView : View {
	var sample: Sample
	var isAnimationEnabled: Bool = true
	
    var body: some View {
		VStack {
			URLImageSourceView(
				url: sample.url,
				isAnimationEnabled: isAnimationEnabled,
				label: Text(sample.name)
			)
			.aspectRatio(contentMode: .fit)
		}
			.padding()
			.navigationBarTitle(Text(sample.name), displayMode: .inline)
    }
}

#if DEBUG
struct SampleView_Previews : PreviewProvider {
    static var previews: some View {
        SampleView(sample: Sample.images[0])
    }
}
#endif
