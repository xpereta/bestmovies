import Foundation

struct MovieDetails: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: Date?
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [Genre]
    let status: String
    let tagline: String?
    let budget: Int
    let revenue: Int
    let originalLanguage: String
    let posterURL: URL?
    let backdropURL: URL?

    init(
        id: Int,
        title: String,
        overview: String,
        releaseDate: Date?,
        voteAverage: Double,
        voteCount: Int,
        runtime: Int?,
        genres: [Genre],
        status: String,
        tagline: String?,
        budget: Int,
        revenue: Int,
        originalLanguage: String,
        posterURL: URL?,
        backdropURL: URL?
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.runtime = runtime
        self.genres = genres
        self.status = status
        self.tagline = tagline
        self.budget = budget
        self.revenue = revenue
        self.originalLanguage = originalLanguage
        self.posterURL = posterURL
        self.backdropURL = backdropURL
    }

    var runtimeFormatted: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)h \(minutes)m"
    }
}

extension MovieDetails: Equatable {
    // Optimized equatable implementation, id is enough for our use cases
    static func == (lhs: MovieDetails, rhs: MovieDetails) -> Bool {
        return lhs.id == rhs.id
    }
}
