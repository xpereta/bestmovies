import Foundation
import TMDBAPI
import Domain

struct GenreMapper {
    static func map(_ dto: TMDBAPI.DTO.Genre) -> Genre {
        return Genre(
            id: dto.id,
            name: dto.name
        )
    }

    static func mapList(_ dto: [TMDBAPI.DTO.Genre]) -> [Genre] {
        return dto.map { map($0) }
    }
}
