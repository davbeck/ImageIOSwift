//
//  File.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

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
		}
	}
}
