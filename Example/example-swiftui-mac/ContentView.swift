import SwiftUI

struct ContentView: View {
	enum Tab {
		case profile
		case animations
	}
	
	@State var tab: Tab = .animations
	
	var body: some View {
		TabbedView(selection: $tab) {
			ProfileView()
				.tabItem {
					Text("Profile")
				}
				.tag(Tab.profile)
			AnimationsView()
				.tabItem {
					Text("Animations")
				}
				.tag(Tab.animations)
		}
	}
}

#if DEBUG
	struct ContentView_Previews: PreviewProvider {
		static var previews: some View {
			ContentView()
		}
	}
#endif
