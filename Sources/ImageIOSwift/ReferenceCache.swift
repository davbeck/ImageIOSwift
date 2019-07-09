//
//  File.swift
//  
//
//  Created by David Beck on 7/7/19.
//

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
		#if canImport(UIKit)
		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
		#endif
	}

	subscript(key: Key) -> Value? {
		get {
			return content.first(where: { $0.key == key })?.value
		}
		set(newValue) {
			content.removeAll(where: { $0.key == key })
			if let newValue = newValue {
				content.append(Content(key: key, value: newValue))
			}
		}
	}

	func clean() {
		let indicesToRemove = content.indices.filter({
			isKnownUniquelyReferenced(&self.content[$0].value)
		}).reversed()

		for index in indicesToRemove {
			content.remove(at: index)
		}
	}
	
	
	// MARK: - Notifications
	
	@objc func didReceiveMemoryWarning(_ notification: Notification) {
		self.clean()
	}
}
