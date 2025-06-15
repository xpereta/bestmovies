@testable import Domain
import Testing

final class GenreTests {

    @Test("Genre initialization")
    func testGenreInitialization() {
        let genre = Genre(id: 1, name: "Action")

        #expect(genre.id == 1)
        #expect(genre.name == "Action")
    }
}
