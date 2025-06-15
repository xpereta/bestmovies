import Foundation

struct Review: Identifiable, Equatable {
    let id: String
    let author: String
    let content: String
    let createdAt: Date?
    let authorDetails: AuthorDetails?

    struct AuthorDetails {
        let name: String?
        let rating: Double?
        let avatarURL: URL?

        init(
            name: String?,
            rating: Double?,
            avatarURL: URL?
        ) {
            self.name = name
            self.rating = rating
            self.avatarURL = avatarURL
        }

        var ratingFormatted: String? {
            guard let rating else { return nil }
            return String(format: "%.1f", rating)
        }
    }

    init(
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

    static func == (lhs: Review, rhs: Review) -> Bool {
        lhs.id == rhs.id
    }
}
