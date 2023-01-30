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

		Sample(url: "http://littlesvr.ca/apng/images/GenevaDrive.gif", categories: [.animated]),
		Sample(url: "http://littlesvr.ca/apng/images/GenevaDrive.png", categories: [.animated]),
		Sample(url: "https://media.giphy.com/media/7LO7q5KcXawaQ/giphy.gif", categories: [.animated]),
		Sample(url: "https://media.giphy.com/media/NWg7M1VlT101W/giphy.gif", categories: [.animated]),
		Sample(url: "https://media.giphy.com/media/l4FGni1RBAR2OWsGk/giphy.gif", categories: [.animated]),

		Sample(url: "http://pooyak.com/p/progjpeg/jpegload.cgi?o=0"),
		Sample(url: "http://pooyak.com/p/progjpeg/jpegload.cgi?o=1"),
	] + ["Landscape", "Portrait"].flatMap { aspect in
		(1 ... 8).map { Sample(filename: "\(aspect)_\($0).jpg", categories: [.orientation]) }
	}

	var id: URL {
		self.url
	}

	var name: String {
		if self.url.isFileURL {
			return self.url.lastPathComponent
		} else {
			return self.url.absoluteString
		}
	}
}
