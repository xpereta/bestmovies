import Foundation
import TMDBAPI

struct ReviewMapper {
    private static let dateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    static func map(_ dto: TMDBAPI.DTO.Review) -> Review {
        let createdAt = dateFormatter.date(from: dto.createdAt)

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

    static func mapList(_ dto: [TMDBAPI.DTO.Review]) -> [Review] {
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
