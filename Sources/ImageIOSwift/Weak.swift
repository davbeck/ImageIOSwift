//
//  Weak.swift
//  ImageIOSwift
//
//  Created by David Beck on 7/8/19.
//

import Foundation


struct Weak<Value: AnyObject> {
	weak var value: Value?
	
	init(_ value: Value) {
		self.value = value
	}
}
