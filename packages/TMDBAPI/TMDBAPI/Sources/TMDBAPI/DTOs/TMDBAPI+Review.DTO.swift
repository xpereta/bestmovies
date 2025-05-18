import Foundation

public extension TMDBAPI.DTO {
    struct ReviewResponse: Decodable {
        public let results: [Review]

        public init(results: [Review]) {
            self.results = results
        }
    }

    struct Review: Decodable {
        public let id: String
        public let author: String
        public let content: String
        public let createdAt: String
        public let authorDetails: AuthorDetails?

        public init(id: String, author: String, content: String, createdAt: String, authorDetails: AuthorDetails?) {
            self.id = id
            self.author = author
            self.content = content
            self.createdAt = createdAt
            self.authorDetails = authorDetails
        }

        enum CodingKeys: String, CodingKey {
            case id
            case author
            case content
            case createdAt = "created_at"
            case authorDetails = "author_details"
        }
    }

    struct AuthorDetails: Decodable {
        public let name: String?
        public let avatarPath: String?
        public let rating: Double?

        public init(name: String?, avatarPath: String?, rating: Double?) {
            self.name = name
            self.avatarPath = avatarPath
            self.rating = rating
        }

        enum CodingKeys: String, CodingKey {
            case name
            case avatarPath = "avatar_path"
            case rating
        }
    }
}
