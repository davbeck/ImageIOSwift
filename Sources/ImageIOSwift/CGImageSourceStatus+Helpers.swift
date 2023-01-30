import Foundation
import ImageIO

extension CGImageSourceStatus: CustomStringConvertible {
	public static let unexpectedEOF = CGImageSourceStatus.statusUnexpectedEOF
	public static let invalidData = CGImageSourceStatus.statusInvalidData
	public static let unknownType = CGImageSourceStatus.statusUnknownType
	public static let readingHeader = CGImageSourceStatus.statusReadingHeader
	public static let incomplete = CGImageSourceStatus.statusIncomplete
	public static let complete = CGImageSourceStatus.statusComplete

	public var description: String {
		switch self {
		case .statusUnexpectedEOF:
			return "UnexpectedEOF"
		case .statusInvalidData:
			return "InvalidData"
		case .statusUnknownType:
			return "UnknownType"
		case .statusReadingHeader:
			return "ReadingHeader"
		case .statusIncomplete:
			return "Incomplete"
		case .statusComplete:
			return "Complete"
		@unknown default:
			return "UnknownStatus(\(rawValue))"
		}
	}
}

public extension ImageSource {
	struct Error: Swift.Error, LocalizedError, CustomStringConvertible {
		public let status: CGImageSourceStatus

		public init?(_ status: CGImageSourceStatus) {
			switch status {
			case .statusReadingHeader, .statusIncomplete, .statusComplete:
				return nil
			default:
				self.status = status
			}
		}

		public var description: String {
			self.status.description
		}

		public var errorDescription: String? {
			switch self.status {
			case .statusUnexpectedEOF:
				return NSLocalizedString("Unexpectedly found the end of the file.", comment: "Error description")
			case .statusInvalidData:
				return NSLocalizedString("Invalid image file.", comment: "Error description")
			case .statusUnknownType:
				return NSLocalizedString("Unsupported image file type.", comment: "Error description")
			case .statusReadingHeader, .statusIncomplete:
				return NSLocalizedString("Still loading image.", comment: "Error description")
			case .statusComplete:
				return nil
			@unknown default:
				return nil
			}
		}
	}
}
