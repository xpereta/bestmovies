import Domain
import Foundation
import TMDBAPI

struct GenreMapper {
    func map(_ dto: TMDBAPI.DTO.Genre) -> Genre {
        Genre(
            id: dto.id,
            name: dto.name
        )
    }

    func mapList(_ dtos: [TMDBAPI.DTO.Genre]) -> [Genre] {
        dtos.map(map)
    }
}
