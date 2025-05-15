import Foundation

struct MovieDetailsMapper {
    private static let dateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    static func map(_ dto: TMDBAPI.DTO.MovieDetails) -> MovieDetails {
        let date = dateFormatter.date(from: dto.releaseDate)

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
