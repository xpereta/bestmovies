import Foundation

struct Review: Identifiable, Equatable {
    let id: String
    let author: String
    let content: String
    let createdAt: Date?
    let authorDetails: AuthorDetails?

    struct AuthorDetails {
        let name: String?
        let avatarPath: String?
        let rating: Double?

        var ratingFormatted: String? {
            guard let rating else { return nil }
            return String(format: "%.1f", rating)
        }

        var avatarURL: URL? {
            guard let avatarPath else { return nil }
            return URL(string: "\(Configuration.posterBaseURL)\(avatarPath)")
        }
    }

    static func == (lhs: Review, rhs: Review) -> Bool {
        lhs.id == rhs.id
    }
}
