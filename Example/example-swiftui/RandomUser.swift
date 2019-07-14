import Combine
import Foundation
import SwiftUI

// MARK: - RandomUsersResponse

struct RandomUsersResponse: Codable {
	let results: [RandomUser]
	let info: Info
}

// MARK: - Info

struct Info: Codable {
	let seed: String
	let results, page: Int
	let version: String
}

// MARK: - RandomUser

struct RandomUser: Codable {
	let gender: Gender
	let name: Name
	let location: Location
	let email: String
	let login: Login
	let dob, registered: Dob
	let phone, cell: String
	let id: ID
	let picture: Picture
	let nat: String
}

// MARK: - Dob

struct Dob: Codable {
	let date: Date
	let age: Int
}

enum Gender: String, Codable {
	case female = "female"
	case male = "male"
}

// MARK: - ID

struct ID: Codable {
	let name: String
	let value: String?
}

// MARK: - Location

struct Location: Codable {
	let street, city, state: String
	let postcode: Postcode
	let coordinates: Coordinates
	let timezone: Timezone
}

// MARK: - Coordinates

struct Coordinates: Codable {
	let latitude, longitude: String
}

enum Postcode: Codable {
	case integer(Int)
	case string(String)
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let x = try? container.decode(Int.self) {
			self = .integer(x)
			return
		}
		if let x = try? container.decode(String.self) {
			self = .string(x)
			return
		}
		throw DecodingError.typeMismatch(Postcode.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Postcode"))
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case let .integer(x):
			try container.encode(x)
		case let .string(x):
			try container.encode(x)
		}
	}
}

// MARK: - Timezone

struct Timezone: Codable {
	let offset, timezoneDescription: String
	
	enum CodingKeys: String, CodingKey {
		case offset
		case timezoneDescription = "description"
	}
}

// MARK: - Login

struct Login: Codable {
	let uuid, username, password, salt: String
	let md5, sha1, sha256: String
}

// MARK: - Name

struct Name: Codable {
	let title: Title
	let first, last: String
}

enum Title: String, Codable {
	case madame = "madame"
	case mademoiselle = "mademoiselle"
	case miss = "miss"
	case monsieur = "monsieur"
	case mr = "mr"
	case mrs = "mrs"
	case ms = "ms"
}

// MARK: - Picture

struct Picture: Codable {
	let large, medium, thumbnail: URL
}
