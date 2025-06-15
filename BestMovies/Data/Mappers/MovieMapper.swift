import Foundation
import TMDBAPI

struct MovieMapper {
    private let dateParseStrategy: Date.ParseStrategy
    private let configurationProvider: ConfigurationProvider
    
    init(
        dateParseStrategy: Date.ParseStrategy = .shortISO8601,
        configurationProvider: ConfigurationProvider
    ) {
        self.dateParseStrategy = dateParseStrategy
        self.configurationProvider = configurationProvider
    }
    
    func map(_ dto: TMDBAPI.DTO.Movie) -> Movie {
        let date = try? Date(dto.releaseDate, strategy: dateParseStrategy)
        var posterURL: URL?
        if let path = dto.posterPath {
            posterURL = URL(string: "\(configurationProvider.posterBaseURL)\(path)")
        }
        
        return Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            releaseDate: date,
            voteAverage: dto.voteAverage,
            posterURL: posterURL
        )
    }

    func mapList(_ dto: [TMDBAPI.DTO.Movie]) -> [Movie] {
        return dto.map { map($0) }
    }
}
