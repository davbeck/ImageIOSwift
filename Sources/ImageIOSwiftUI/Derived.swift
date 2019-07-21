import Combine
import SwiftUI

/// Create derived state that might be expensive to create on every evaluation.
///
/// If you have a value that is expensive to create (something that requires IO to create for instance), you can use this to generate the value only once per source value. When the value stays the same, the derived value will continue to be used, and when the source changes, a new derived value will be created.
///
/// If Derived is a BindableObject, content will be called each time it changes, so you do not need to create an additional binding.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Derived<Source: Hashable, Derived, ChildView: View>: View {
	// delays generation of a value until it is needed, then uses that value after that
	// this has to be a class because value types can't be updated when evaluating body
	fileprivate class Lazy {
		var source: Source
		var derived: (Source) -> Derived
		
		init(from source: Source, using derived: @escaping (Source) -> Derived) {
			self.source = source
			self.derived = derived
		}
		
		private var _value: Derived?
		var value: Derived {
			get {
				if let value = self._value {
					return value
				} else {
					let value = self.derived(self.source)
					self._value = value
					return value
				}
			}
			set {
				self._value = newValue
			}
		}
	}
	
	// keeps track of the lazy value using @State
	// this has to be separate from the parent because `id()` is applied there and that's how state is reset
	private struct Storage: View {
		@State fileprivate var derived: Lazy
		fileprivate var content: (Derived) -> ChildView
		
		var body: some View {
			return self.content(derived.value)
		}
	}
	
	public var source: Source
	public var derived: (Source) -> Derived
	public var content: (Derived) -> ChildView
	
	public init(from source: Source, using derived: @escaping (Source) -> Derived, content: @escaping (Derived) -> ChildView) {
		self.source = source
		self.derived = derived
		self.content = content
	}
	
	public var body: some View {
		return Storage(
			derived: Lazy(from: source, using: derived),
			content: content
		)
		.id(source)
	}
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Derived.Lazy: Identifiable where Derived: Identifiable {
	var id: Derived.ID {
		return value.id
	}
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Derived.Lazy: DynamicViewProperty where Derived: DynamicViewProperty {
	func update() {
		self.value.update()
	}
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Derived.Lazy: BindableObject, _BindableObjectViewProperty where Derived: BindableObject {
	var willChange: Derived.PublisherType {
		self.value.willChange
	}
}
