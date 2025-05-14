import Foundation

extension TMDBAPI.DTO {
    struct MovieDetails: Decodable {
        let id: Int
        let title: String
        let overview: String
        let posterPath: String?
        let backdropPath: String?
        let releaseDate: String
        let voteAverage: Double
        let voteCount: Int
        let runtime: Int?
        let genres: [Genre]
        let status: String
        let tagline: String?
        let budget: Int
        let revenue: Int
        let originalLanguage: String
        
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
