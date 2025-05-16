import Foundation

extension TMDBAPI.DTO {
    struct ReviewResponse: Decodable {
        let results: [Review]
    }

    struct Review: Decodable {
        let id: String
        let author: String
        let content: String
        let createdAt: String
        let authorDetails: AuthorDetails?

        enum CodingKeys: String, CodingKey {
            case id
            case author
            case content
            case createdAt = "created_at"
            case authorDetails = "author_details"
        }
    }

    struct AuthorDetails: Decodable {
        let name: String?
        let avatarPath: String?
        let rating: Double?

        enum CodingKeys: String, CodingKey {
            case name
            case avatarPath = "avatar_path"
            case rating
        }
    }
}
