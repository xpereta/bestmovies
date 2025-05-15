import Foundation

struct Movie: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: Date?  // We allow nil release dates because an error in date parser should not break the app
    let voteAverage: Double

    var posterURL: URL? {
        guard let posterPath else { return nil }
        #warning("Poster URLs should be in configuration")
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
}

extension Movie: Equatable {
    // Optimized equatable implementation, id is enough for our use cases
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
