//
//  Sample.swift
//  example-swiftui-mac
//
//  Created by David Beck on 7/12/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI


struct Sample: Identifiable {
	enum Category {
		case animated
		case orientation
	}
	
	var url: URL
	var categories: Set<Category>
	
	init(filename: String, categories: Set<Category> = []) {
		self.url = Bundle.main.url(forResource: filename, withExtension: nil)!
		self.categories = categories
	}
	
	init(url: String, categories: Set<Category> = []) {
		self.url = URL(string: url)!
		self.categories = categories
	}
	
	static let images = [
		Sample(filename: "animated.gif", categories: [.animated]),
		Sample(filename: "transparent.gif", categories: [.animated]),
		Sample(filename: "animated.png", categories: [.animated]),
		Sample(filename: "transparent.png", categories: [.animated]),
		Sample(filename: "starfield_animation.heic", categories: [.animated]),
		Sample(filename: "sea1_animation.heic", categories: [.animated]),
		
		Sample(url: "https://media.giphy.com/media/7LO7q5KcXawaQ/giphy.gif", categories: [.animated]),
		Sample(url: "https://media.giphy.com/media/NWg7M1VlT101W/giphy.gif", categories: [.animated]),
		Sample(url: "https://media.giphy.com/media/l4FGni1RBAR2OWsGk/giphy.gif", categories: [.animated]),
		
		] + ["Landscape", "Portrait"].flatMap({ (aspect) in
			(1...8).map({ Sample(filename: "\(aspect)_\($0).jpg", categories: [.orientation]) })
		})
	
	var id: URL {
		return url
	}
	
	var name: String {
		if url.isFileURL {
			return url.lastPathComponent
		} else {
			return url.absoluteString
		}
	}
}
