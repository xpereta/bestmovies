import Foundation

public struct Review: Identifiable, Equatable {
    public let id: String
    public let author: String
    public let content: String
    public let createdAt: Date?
    public let authorDetails: AuthorDetails?

    public struct AuthorDetails {
        public let name: String?
        public let rating: Double?
        public let avatarURL: URL?

        public init(
            name: String?,
            rating: Double?,
            avatarURL: URL?
        ) {
            self.name = name
            self.rating = rating
            self.avatarURL = avatarURL
        }

        public var ratingFormatted: String? {
            guard let rating else { return nil }
            return String(format: "%.1f", rating)
        }
    }

    public init(
        id: String,
        author: String,
        content: String,
        createdAt: Date?,
        authorDetails: AuthorDetails?
    ) {
        self.id = id
        self.author = author
        self.content = content
        self.createdAt = createdAt
        self.authorDetails = authorDetails
    }

    public static func == (lhs: Review, rhs: Review) -> Bool {
        lhs.id == rhs.id
    }
}