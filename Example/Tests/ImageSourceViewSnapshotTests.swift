import XCTest
import FBSnapshotTestCase
import ImageIOSwift


class ImageSourceViewSnapshotTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
		
//		recordMode = true
    }
	
	
	// MARK: - Tests
    
    func testOrientations() {
		let view = ImageSourceView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		
		for name in ["Landscape", "Portrait"] {
			for orientation in (1...8) {
				guard let url = local(named: "\(name)_\(orientation).jpg") else { XCTFail(); return }
				let expectedSize = UIImage(contentsOfFile: url.path)?.size
				
				let source = ImageSource(url: url)
				view.imageSource = source
				XCTAssertEqual(view.intrinsicContentSize, expectedSize, "\(name) \(orientation) intrinsicContentSize")
				
				FBSnapshotVerifyView(view, identifier: "\(name)_\(orientation)")
			}
		}
    }
	
	func testContentMode() {
		let view = ImageSourceView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		view.backgroundColor = .lightGray
		
		guard let url = local(named: "small.jpeg") else { XCTFail(); return }
		let expectedSize = UIImage(contentsOfFile: url.path)?.size
		
		view.imageSource = ImageSource(url: url)
		
		let modes: [UIViewContentMode] = [
			.scaleToFill,
			.scaleAspectFit,
			.scaleAspectFill,
			.center,
			.top,
			.bottom,
			.left,
			.right,
			.topLeft,
			.topRight,
			.bottomLeft,
			.bottomRight,
		]
		for mode in modes {
			view.contentMode = mode
			XCTAssertEqual(view.intrinsicContentSize, expectedSize, "content mode \(mode)")
			
			FBSnapshotVerifyView(view, identifier: "\(mode)")
		}
	}
}
