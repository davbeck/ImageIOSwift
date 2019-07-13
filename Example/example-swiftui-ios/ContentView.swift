import SwiftUI

struct ContentView: View {
	var body: some View {
		NavigationView {
			List {
				NavigationLink(destination: ProfileView()) {
					Text("Profile Screen")
				}
				NavigationLink(destination: UserListView()) {
					Text("User List")
				}
				NavigationLink(destination: AnimationsView()) {
					Text("Animations")
				}
				NavigationLink(destination: OrientationsView()) {
					Text("EXIF Orientations")
				}
			}
			.navigationBarTitle("Examples")
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
