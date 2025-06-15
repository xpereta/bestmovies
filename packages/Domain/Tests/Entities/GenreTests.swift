@testable import Domain
import Testing

final class GenreTests {

    @Test("Genre initialization")
    func testGenreInitialization() {
        let genre = Genre(id: 1, name: "Action")

        #expect(genre.id == 1)
        #expect(genre.name == "Action")
    }

    @Test("Genre equality comparison")
    func testGenreEquality() {
        let genre1 = Genre(id: 1, name: "Action")
        let genre2 = Genre(id: 1, name: "Drama") // Same ID, but different name
        let genre3 = Genre(id: 2, name: "Action") // Different ID, but same name

        // Genres with same ID should be equal regardless of name
        #expect(genre1 == genre2)
        // Genres with different IDs should not be equal
        #expect(genre1 != genre3)
    }
}
