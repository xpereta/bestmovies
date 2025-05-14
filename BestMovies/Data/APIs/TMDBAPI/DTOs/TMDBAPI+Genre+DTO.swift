import Foundation

extension TMDBAPI.DTO {
    struct Genre: Decodable {
        let id: Int
        let name: String
    }
}
