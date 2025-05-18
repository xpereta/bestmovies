import Foundation
import TMDBAPI

struct MovieMapper {
    private static let dateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    static func map(_ dto: TMDBAPI.DTO.Movie) -> Movie {
        let date = dateFormatter.date(from: dto.releaseDate)

        return Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            releaseDate: date,
            voteAverage: dto.voteAverage
        )
    }

    static func mapList(_ dto: [TMDBAPI.DTO.Movie]) -> [Movie] {
        return dto.map { map($0) }
    }
}
