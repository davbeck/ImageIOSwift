//
//  CADisplayLink+Callbacks.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

#if os(iOS)
import QuartzCore


extension CADisplayLink {
	private class Proxy {
		let callback: (CADisplayLink) -> Void
		init(callback: @escaping (CADisplayLink) -> Void) {
			self.callback = callback
		}
		
		@objc func fire(_ link: CADisplayLink) {
			callback(link)
		}
	}
	
	convenience init(callback: @escaping (CADisplayLink) -> Void) {
		let proxy = Proxy(callback: callback)
		
		self.init(target: proxy, selector: #selector(Proxy.fire))
	}
}
#endif
