import Foundation

struct ReviewMapper {
    private let dateParseStrategy: Date.ParseStrategy

    init(dateParseStrategy: Date.ParseStrategy = .shortISO8601) {
        self.dateParseStrategy = dateParseStrategy
    }

    func map(_ dto: TMDBAPI.DTO.Review) -> Review {
        let createdAt = try? Date(dto.createdAt, strategy: dateParseStrategy)

        var authorDetails: Review.AuthorDetails?

        if let authorDetailsDTO = dto.authorDetails {
            authorDetails = AuthorDetailsMapper.map(authorDetailsDTO)
        }

        return Review(
            id: dto.id,
            author: dto.author,
            content: dto.content,
            createdAt: createdAt,
            authorDetails: authorDetails
        )
    }

    func mapList(_ dto: [TMDBAPI.DTO.Review]) -> [Review] {
        return dto.map { map($0) }
    }

    struct AuthorDetailsMapper {
        static func map(_ dto: TMDBAPI.DTO.AuthorDetails) -> Review.AuthorDetails {
            return Review.AuthorDetails(
                name: dto.name,
                avatarPath: dto.avatarPath,
                rating: dto.rating
            )
        }
    }
}
