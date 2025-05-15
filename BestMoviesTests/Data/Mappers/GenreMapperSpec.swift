@testable import BestMovies
import Foundation
import Nimble
import Quick

class GenreMapperSpec: QuickSpec {
    override class func spec() {
        describe("GenreMapper") {
            context("when mapping a single DTO") {
                it("maps all properties correctly") {
                    let dto = TMDBAPI.DTO.Genre(
                        id: 28,
                        name: "Action"
                    )

                    let genre = GenreMapper.map(dto)

                    expect(genre.id).to(equal(28))
                    expect(genre.name).to(equal("Action"))
                }
            }

            context("when mapping multiple DTOs") {
                it("maps all DTOs correctly") {
                    let dtos = [
                        TMDBAPI.DTO.Genre(id: 28, name: "Action"),
                        TMDBAPI.DTO.Genre(id: 12, name: "Adventure"),
                        TMDBAPI.DTO.Genre(id: 878, name: "Science Fiction")
                    ]

                    let genres = GenreMapper.mapList(dtos)

                    expect(genres).to(haveCount(3))
                    expect(genres[0].name).to(equal("Action"))
                    expect(genres[1].name).to(equal("Adventure"))
                    expect(genres[2].name).to(equal("Science Fiction"))
                }

                it("returns empty array when given empty input") {
                    let genres = GenreMapper.mapList([])

                    expect(genres).to(beEmpty())
                }
            }

            context("Genre model equality") {
                it("considers two genres equal if they have the same id and name") {
                    let genre1 = Genre(id: 28, name: "Action")
                    let genre2 = Genre(id: 28, name: "Action")

                    expect(genre1).to(equal(genre2))
                }

                it("considers genres with different ids as not equal") {
                    let genre1 = Genre(id: 28, name: "Action")
                    let genre2 = Genre(id: 12, name: "Action")

                    expect(genre1).notTo(equal(genre2))
                }

                it("considers genres with different names as not equal") {
                    let genre1 = Genre(id: 28, name: "Action")
                    let genre2 = Genre(id: 28, name: "Adventure")

                    expect(genre1).notTo(equal(genre2))
                }
            }
        }
    }
}
