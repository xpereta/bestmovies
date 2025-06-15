import Foundation

extension TMDBAPI.DTO {
    struct PageInfo: Decodable {
        public let count: Int
        public let pages: Int
        public let next: String?
        public let prev: String?
    }
}
