import Combine
import Foundation
import ImageIOSwiftUI
import SwiftUI

extension Publisher {
	func mapToResult() -> Publishers.Catch<Publishers.Map<Self, Result<Output, Error>>, Just<Result<Output, Error>>> {
		return self
			.map { Result<Output, Error>.success($0) }
			.catch { Just(Result<Output, Error>.failure($0)) }
	}
}

struct RandomUsersResponseView: View {
	var response: RandomUsersResponse
	
	var body: some View {
		List(response.results, id: \.login.uuid) { user in
			HStack {
				ZStack {
					Placeholder()
					URLImageSourceView(user.picture.medium)
						.frame(width: 36, height: 36)
				}
				.frame(width: 36, height: 36)
				.background(Color(white: 0.8))
				.clipShape(Circle())
				Text("\(user.name.first.capitalized) \(user.name.last.capitalized)")
			}
		}
		.navigationBarTitle(Text("Users"), displayMode: .inline)
	}
}

struct UserListView: View {
	@State var task = URLSession.shared.dataTaskPublisher(for: URL(string: "https://randomuser.me/api/?results=100")!)
		.tryMap { (data, _) -> RandomUsersResponse in
			var decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			return try decoder.decode(RandomUsersResponse.self, from: data)
		}
		.print()
		.mapToResult()
		.receive(on: RunLoop.main)
	
	@State var result: Result<RandomUsersResponse, Error>? = nil
	
	var body: some View {
		switch result {
		case .none:
			return AnyView(Text("Loading...")
				.onReceive(task) {
					self.result = $0
			})
		case let .success(response):
			return AnyView(RandomUsersResponseView(response: response))
		case let .failure(error):
			return AnyView(Text("Failed to load: \(error.localizedDescription)"))
		}
	}
}

#if DEBUG
	struct UserListView_Previews: PreviewProvider {
		static var previews: some View {
			UserListView()
		}
	}
#endif
