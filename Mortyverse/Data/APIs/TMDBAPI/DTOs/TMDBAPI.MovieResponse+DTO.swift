import Foundation

extension TMDBAPI.DTO {
    struct MovieResponse: Decodable {
        let page: Int
        let results: [Movie]
        let totalPages: Int
        
        enum CodingKeys: String, CodingKey {
            case page
            case results
            case totalPages = "total_pages"
        }
    }
    
    struct Movie: Decodable {
        let id: Int
        let title: String
        let overview: String
        let posterPath: String?
        let releaseDate: String
        let voteAverage: Double
        
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
