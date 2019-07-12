//
//  ProfileView.swift
//  example-swiftui-ios
//
//  Created by David Beck on 7/11/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import ImageIOSwiftUI

let uifaces = ["men", "women"]
	.flatMap({ gender in
		(0..<100).map({ "https://randomuser.me/api/portraits/\(gender)/\($0).jpg" })
	})
	.compactMap({ URL(string: $0) })

let names = [
	"John",
	"Jane",
	"Frank",
	"Julie",
]

struct ProfileView: View {
	@State var url: URL = uifaces.randomElement()!
	@State var name: String = names.randomElement()!
	
	var body: some View {
		VStack {
			ZStack {
				Image(systemName: "person.fill")
					.font(.system(size: 80))
					.foregroundColor(Color(white: 0.4))
				URLImageSourceView(url: url, isAnimationEnabled: true, label: Text(url.lastPathComponent))
					.aspectRatio(contentMode: .fit)
					.frame(width: 128, height: 128)
					.clipShape(Circle())
			}
				.padding(5)
				.background(Color.gray.opacity(0.5))
				.clipShape(Circle())
			Text(self.name)
			Spacer()
			HStack {
				Button("Update avatar") {
					self.url = uifaces.randomElement()!
				}
				Spacer().frame(width: 20)
				Button("Update name") {
					self.name = names.randomElement()! + " \(Int.random(in: 0..<100))"
				}
			}
			Spacer()
			Text("This demonstrates how URLImageSourceView reacts to changes to it's url as well as changes that don't effect it's url.")
				.lineLimit(nil)
			.multilineTextAlignment(.center)
		}
			.padding()
			.navigationBarTitle("Profile")
	}
}
