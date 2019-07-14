//
//  NavigationView.swift
//  ImageIOSwift_Example
//
//  Created by David Beck on 7/14/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI

// NavigationView isn't available on watchOS, but isn't needed
// this allows us to use the same code for all platforms

struct NavigationView<Content>: View where Content : View {
	var content: Content
	init(content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		return content
	}
}
