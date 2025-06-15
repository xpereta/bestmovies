import Foundation

public struct MovieDetails: Identifiable {
    public let id: Int
    public let title: String
    public let overview: String
    public let releaseDate: Date?
    public let voteAverage: Double
    public let voteCount: Int
    public let runtime: Int?
    public let genres: [Genre]
    public let status: String
    public let tagline: String?
    public let budget: Int
    public let revenue: Int
    public let originalLanguage: String
    public let posterURL: URL?
    public let backdropURL: URL?

    public init(
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

    public var runtimeFormatted: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)h \(minutes)m"
    }
}

extension MovieDetails: Equatable {
    // Optimized equatable implementation, id is enough for our use cases
    public static func == (lhs: MovieDetails, rhs: MovieDetails) -> Bool {
        return lhs.id == rhs.id
    }
}