import Foundation
import Quick
import Nimble
@testable import Mortyverse

class CharacterDTOMapperSpec: QuickSpec {
    private static let dateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    override class func spec() {
        describe("CharacterDTOMapper") {
            context("when mapping a single DTO") {
                context("with valid information") {
                    it("maps all properties correctly") {
                        let dto = CharacterDTO(
                            id: 1,
                            name: "Rick Sanchez",
                            created: "2017-11-04T18:48:46.250Z",
                            image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
                        )
                        
                        let character = CharacterDTOMapper.map(dto)
                        
                        expect(character.id).to(equal(1))
                        expect(character.name).to(equal("Rick Sanchez"))
                        expect(character.image).to(equal("https://rickandmortyapi.com/api/character/avatar/1.jpeg"))
                        
                        let expectedDate = dateFormatter.date(from: "2017-11-04T18:48:46.250Z")
                        expect(character.created).to(equal(expectedDate))
                    }
                }
                
                context("with invalid date") {
                    it("returns distant past as fallback date") {
                        let dto = CharacterDTO(
                            id: 1,
                            name: "Rick Sanchez",
                            created: "invalid-date",
                            image: "https://example.com/image.jpg"
                        )
                        
                        let character = CharacterDTOMapper.map(dto)
                        
                        expect(character.created).to(equal(Date.distantPast))
                    }
                }
                
                context("when mapping multiple DTOs") {
                    it("maps all DTOs correctly") {
                        let dtos = [
                            CharacterDTO(
                                id: 1,
                                name: "Rick",
                                created: "2017-11-04T18:48:46.250Z",
                                image: "https://example.com/rick.jpg"
                            ),
                            CharacterDTO(
                                id: 2,
                                name: "Morty",
                                created: "2017-11-04T18:50:21.651Z",
                                image: "https://example.com/morty.jpg"
                            )
                        ]
                        
                        let characters = CharacterDTOMapper.mapList(dtos)
                        
                        expect(characters).to(haveCount(2))
                        expect(characters[0].name).to(equal("Rick"))
                        expect(characters[1].name).to(equal("Morty"))
                    }
                    
                    it("returns empty array when given empty input") {
                        let characters = CharacterDTOMapper.mapList([])
                        
                        expect(characters).to(beEmpty())
                    }
                }
            }
        }
    }
}
