import Foundation

func local(named name: String) -> URL? {
	Bundle.main.url(forResource: name, withExtension: nil)
}
