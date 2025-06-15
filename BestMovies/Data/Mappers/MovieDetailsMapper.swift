import Foundation
import TMDBAPI

struct MovieDetailsMapper {
    private let dateParseStrategy: Date.ParseStrategy
    private let configurationProvider: ConfigurationProvider

    init(
        dateParseStrategy: Date.ParseStrategy = .shortISO8601,
        configurationProvider: ConfigurationProvider
    ) {
        self.dateParseStrategy = dateParseStrategy
        self.configurationProvider = configurationProvider
    }

    func map(_ dto: TMDBAPI.DTO.MovieDetails) -> MovieDetails {
        let date = try? Date(dto.releaseDate, strategy: dateParseStrategy)
        var posterURL: URL?
        if let path = dto.posterPath {
            posterURL = URL(string: "\(configurationProvider.posterBaseURL)\(path)")
        }
        var backdropURL: URL?
        if let path = dto.backdropPath {
            backdropURL = URL(string: "\(configurationProvider.backdropBaseURL)\(path)")
        }

        return MovieDetails(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            releaseDate: date,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            runtime: dto.runtime,
            genres: dto.genres.map { Genre(id: $0.id, name: $0.name) },
            status: dto.status,
            tagline: dto.tagline,
            budget: dto.budget,
            revenue: dto.revenue,
            originalLanguage: dto.originalLanguage,
            posterURL: posterURL,
            backdropURL: backdropURL
        )
    }
}
