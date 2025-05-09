import Foundation

struct CharacterDTOMapper {
    private static let dateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    static func map(_ dto: CharacterDTO) -> Character {
        let created = dateFormatter.date(from: dto.created) ?? Date.distantPast
        
        return Character(
            id: dto.id,
            name: dto.name,
            created: created,
            image: dto.image,
            species: dto.species,
            gender: dto.gender
        )
    }
    
    static func mapList(_ dto: [CharacterDTO]) -> [Character] {
        return dto.map { map($0) }
    }
}
