import SwiftUI

enum DisplayMode {
	case inline
}

extension View {
	func navigationBarTitle(_: String) -> Self {
		return self
	}
	
	func navigationBarTitle(_: Text, displayMode _: DisplayMode) -> Self {
		return self
	}
}
