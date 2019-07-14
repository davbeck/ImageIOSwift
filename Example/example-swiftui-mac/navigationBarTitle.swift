//
//  navigationBarTitle.swift
//  example-swiftui-mac
//
//  Created by David Beck on 7/14/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI

enum DisplayMode {
	case inline
}

extension View {
	func navigationBarTitle(_ title: String) -> Self {
		return self
	}
	
	func navigationBarTitle(_ title: Text, displayMode: DisplayMode) -> Self {
		return self
	}
}
