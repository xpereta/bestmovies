import Foundation
import TMDBAPI

struct ReviewMapper {
    private let dateParseStrategy: Date.ParseStrategy
    private let configurationProvider: ConfigurationProvider
    
    init(
        dateParseStrategy: Date.ParseStrategy = .shortISO8601,
        configurationProvider: ConfigurationProvider
    ) {
        self.dateParseStrategy = dateParseStrategy
        self.configurationProvider = configurationProvider
    }
    
    func map(_ dto: TMDBAPI.DTO.Review) -> Review {
        let createdAt = try? Date(dto.createdAt, strategy: dateParseStrategy)

        var authorDetails: Review.AuthorDetails?

        if let authorDetailsDTO = dto.authorDetails {
            authorDetails = AuthorDetailsMapper.map(authorDetailsDTO, configurationProvider: configurationProvider)
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
        static func map(_ dto: TMDBAPI.DTO.AuthorDetails, configurationProvider: ConfigurationProvider) -> Review.AuthorDetails {
            var avatarURL: URL?
            if let path = dto.avatarPath {
                avatarURL = URL(string: "\(configurationProvider.avatarBaseURL)\(path)")
            }

            return Review.AuthorDetails(
                name: dto.name,
                rating: dto.rating,
                avatarURL: avatarURL
            )
        }
    }
}
