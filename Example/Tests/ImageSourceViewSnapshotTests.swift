import FBSnapshotTestCase
import ImageIOSwift
import ImageIOUIKit
import XCTest

class ImageSourceViewSnapshotTests: FBSnapshotTestCase {
	override func setUp() {
		super.setUp()

		//		recordMode = true
	}

	// MARK: - Tests

	func testOrientations() {
		let view = ImageSourceView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

		for name in ["Landscape", "Portrait"] {
			for orientation in 1 ... 8 {
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

		let modes: [UIView.ContentMode] = [
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

	func testIncrementalLoad() throws {
		let view = ImageSourceView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		view.backgroundColor = .lightGray

		guard let url = local(named: "progressive.jpeg") else { XCTFail(); return }
		let data = try Data(contentsOf: url)

		let imageSource = ImageSource.incremental()
		view.imageSource = imageSource
		FBSnapshotVerifyView(view, identifier: "0%")

		imageSource.update(data.prefix(data.count / 10), isFinal: false)
		FBSnapshotVerifyView(view, identifier: "10%")

		imageSource.update(data.prefix(data.count / 4), isFinal: false)
		FBSnapshotVerifyView(view, identifier: "50%")

		imageSource.update(data, isFinal: false)
		FBSnapshotVerifyView(view, identifier: "100%")
	}
}
