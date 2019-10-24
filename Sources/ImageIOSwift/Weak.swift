import Foundation

struct Weak<Value: AnyObject> {
	weak var value: Value?
	
	init(_ value: Value) {
		self.value = value
	}
}
