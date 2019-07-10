import Foundation

func local(named name: String) -> URL? {
    return Bundle.main.url(forResource: name, withExtension: nil)
}
