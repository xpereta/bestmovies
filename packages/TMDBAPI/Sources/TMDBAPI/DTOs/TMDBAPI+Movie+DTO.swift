import Foundation
import Domain

public extension TMDBAPI.DTO {
    struct MovieResponse: Decodable {
        public let page: Int
        public let results: [Movie]
        public let totalPages: Int

        public init(page: Int, results: [Movie], totalPages: Int) {
            self.page = page
            self.results = results
            self.totalPages = totalPages
        }

        enum CodingKeys: String, CodingKey {
            case page
            case results
            case totalPages = "total_pages"
        }
    }

    struct Movie: Decodable {
        public let id: Int
        public let title: String
        public let overview: String
        public let posterPath: String?
        public let releaseDate: String
        public let voteAverage: Double

        public init(id: Int, title: String, overview: String, posterPath: String?, releaseDate: String, voteAverage: Double) {
            self.id = id
            self.title = title
            self.overview = overview
            self.posterPath = posterPath
            self.releaseDate = releaseDate
            self.voteAverage = voteAverage
        }

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case overview
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case voteAverage = "vote_average"
        }
    }
}
