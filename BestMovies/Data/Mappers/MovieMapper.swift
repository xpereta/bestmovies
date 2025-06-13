import Foundation

struct MovieMapper {
    private let dateParseStrategy: Date.ParseStrategy

    init(dateParseStrategy: Date.ParseStrategy = .shortISO8601) {
        self.dateParseStrategy = dateParseStrategy
    }

    func map(_ dto: TMDBAPI.DTO.Movie) -> Movie {
        let date = try? Date(dto.releaseDate, strategy: dateParseStrategy)

        return Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            releaseDate: date,
            voteAverage: dto.voteAverage
        )
    }

    func mapList(_ dto: [TMDBAPI.DTO.Movie]) -> [Movie] {
        return dto.map { map($0) }
    }
}
