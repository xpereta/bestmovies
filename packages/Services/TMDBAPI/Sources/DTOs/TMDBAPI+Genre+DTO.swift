import Foundation

public extension TMDBAPI.DTO {
    struct Genre: Decodable {
        public let id: Int
        public let name: String

        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
    }
}
