import Foundation
#if canImport(UIKit)
	import UIKit
#endif

/// A cache that removes elements once they are no longer used (retained).
class ReferenceCache<Key: Equatable, Value: AnyObject> {
	private struct Content {
		var key: Key
		var value: Value
	}
	
	private var content: [Content] = []
	
	init() {
		#if os(iOS) || os(tvOS)
			NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
		#endif
	}
	
	subscript(key: Key) -> Value? {
		get {
			return self.content.first(where: { $0.key == key })?.value
		}
		set(newValue) {
			self.content.removeAll(where: { $0.key == key })
			if let newValue = newValue {
				self.content.append(Content(key: key, value: newValue))
			}
		}
	}
	
	func clean() {
		let indicesToRemove = self.content.indices.filter {
			isKnownUniquelyReferenced(&self.content[$0].value)
		}.reversed()
		
		for index in indicesToRemove {
			self.content.remove(at: index)
		}
	}
	
	// MARK: - Notifications
	
	@objc func didReceiveMemoryWarning(_: Notification) {
		self.clean()
	}
}
