import Foundation

struct MovieDetailsMapper {
    private let dateParseStrategy: Date.ParseStrategy

    init(dateParseStrategy: Date.ParseStrategy = .shortISO8601) {
        self.dateParseStrategy = dateParseStrategy
    }

    func map(_ dto: TMDBAPI.DTO.MovieDetails) -> MovieDetails {
        let date = try? Date(dto.releaseDate, strategy: dateParseStrategy)

        return MovieDetails(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            releaseDate: date,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            runtime: dto.runtime,
            genres: dto.genres.map { Genre(id: $0.id, name: $0.name) },
            status: dto.status,
            tagline: dto.tagline,
            budget: dto.budget,
            revenue: dto.revenue,
            originalLanguage: dto.originalLanguage
        )
    }
}
