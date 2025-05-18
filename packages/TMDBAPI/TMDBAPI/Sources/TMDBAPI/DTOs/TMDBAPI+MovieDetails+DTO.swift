import Foundation

public extension TMDBAPI.DTO {
    struct MovieDetails: Decodable {
        public let id: Int
        public let title: String
        public let overview: String
        public let posterPath: String?
        public let backdropPath: String?
        public let releaseDate: String
        public let voteAverage: Double
        public let voteCount: Int
        public let runtime: Int?
        public let genres: [Genre]
        public let status: String
        public let tagline: String?
        public let budget: Int
        public let revenue: Int
        public let originalLanguage: String

        public init(id: Int, title: String, overview: String, posterPath: String?, backdropPath: String?, releaseDate: String, voteAverage: Double, voteCount: Int, runtime: Int?, genres: [Genre], status: String, tagline: String?, budget: Int, revenue: Int, originalLanguage: String) {
            self.id = id
            self.title = title
            self.overview = overview
            self.posterPath = posterPath
            self.backdropPath = backdropPath
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
        }

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case overview
            case posterPath = "poster_path"
            case backdropPath = "backdrop_path"
            case releaseDate = "release_date"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
            case runtime
            case genres
            case status
            case tagline
            case budget
            case revenue
            case originalLanguage = "original_language"
        }
    }
}
