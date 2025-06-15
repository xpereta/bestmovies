import Foundation

public struct Movie: Identifiable {
    public let id: Int
    public let title: String
    public let overview: String
    public let releaseDate: Date?  // We allow nil release dates because an error in date parser should not break the app
    public let voteAverage: Double
    public let posterURL: URL?

    public init(
        id: Int,
        title: String,
        overview: String,
        releaseDate: Date?,
        voteAverage: Double,
        posterURL: URL?
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.posterURL = posterURL
    }
}

extension Movie: Equatable {
    // Optimized equatable implementation, id is enough for our use cases
    public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
