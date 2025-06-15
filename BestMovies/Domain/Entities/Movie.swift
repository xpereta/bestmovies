import Foundation

struct Movie: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: Date?  // We allow nil release dates because an error in date parser should not break the app
    let voteAverage: Double
    let posterURL: URL?

    init(
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
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
