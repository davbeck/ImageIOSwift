import UIKit
import XCTest
import ImageIOSwift

class SizeTests: XCTestCase {
    // MARK: - Tests
    
    func testOrientations() throws {
		for name in ["Landscape", "Portrait"] {
			for orientation in (1...8) {
				guard let url = local(named: "\(name)_\(orientation).jpg") else { XCTFail(); return }
				let expectedSize = UIImage(contentsOfFile: url.path)?.size
				
				let source = ImageSource(url: url)
				XCTAssertEqual(source?.properties(at: 0)?.imageSize, expectedSize, "\(name) \(orientation) properties")
				XCTAssertEqual(source?.image(at: 0)?.size, expectedSize, "\(name) \(orientation) image")
			}
		}
    }
}
