import XCTest

#if !canImport(ObjectiveC)
	public func allTests() -> [XCTestCaseEntry] {
		[
			testCase(ImageIOSwiftTests.allTests),
		]
	}
#endif
