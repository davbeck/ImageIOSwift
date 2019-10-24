import Combine
import Foundation
import SwiftUI

// MARK: - RandomUsersResponse

struct RandomUsersResponse: Codable {
	let results: [RandomUser]
}

// MARK: - RandomUser

struct RandomUser: Codable {
	let name: Name
	let login: Login
	let picture: Picture
}

// MARK: - Login

struct Login: Codable {
	let uuid: String
}

// MARK: - Name

struct Name: Codable {
	let first, last: String
}

// MARK: - Picture

struct Picture: Codable {
	let large, medium, thumbnail: URL
}
