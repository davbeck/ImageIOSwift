import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	var window: NSWindow!
	
	func applicationDidFinishLaunching(_: Notification) {
		// Insert code here to initialize your application
		self.window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered, defer: false
		)
		self.window.center()
		self.window.setFrameAutosaveName("Main Window")
		
		self.window.contentView = NSHostingView(rootView: ContentView())
		
		self.window.makeKeyAndOrderFront(nil)
	}
	
	func applicationWillTerminate(_: Notification) {
		// Insert code here to tear down your application
	}
}
