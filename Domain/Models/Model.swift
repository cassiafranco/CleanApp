import Foundation

public protocol Model: Encodable, Decodable, Equatable {}

public extension Model {
    func toData() -> Data? {
        return try?  JSONEncoder().encode(self)
    }
}
