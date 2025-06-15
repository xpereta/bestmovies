@testable import Domain
import Foundation
import Testing

final class MovieTests {

    @Test("Movie initialization with all properties")
    func testMovieInitialization() {
        let date = Date()
        let posterURL = URL(string: "https://example.com/poster.jpg")

        let movie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            releaseDate: date,
            voteAverage: 8.5,
            posterURL: posterURL
        )

        #expect(movie.id == 1)
        #expect(movie.title == "Test Movie")
        #expect(movie.overview == "Test Overview")
        #expect(movie.releaseDate == date)
        #expect(movie.voteAverage == 8.5)
        #expect(movie.posterURL == posterURL)
    }

    @Test("Movie initialization with nil values")
    func testMovieInitializationWithNilValues() {
        let movie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            releaseDate: nil,
            voteAverage: 8.5,
            posterURL: nil
        )

        #expect(movie.id == 1)
        #expect(movie.title == "Test Movie")
        #expect(movie.overview == "Test Overview")
        #expect(movie.releaseDate == nil)
        #expect(movie.voteAverage == 8.5)
        #expect(movie.posterURL == nil)
    }

    @Test("Movie equality comparison")
    func testMovieEquality() {
        let movie1 = Movie(
            id: 1,
            title: "Movie 1",
            overview: "Overview 1",
            releaseDate: nil,
            voteAverage: 8.0,
            posterURL: nil
        )

        let movie2 = Movie(
            id: 1,
            title: "Movie 2", // Different title
            overview: "Overview 2", // Different overview
            releaseDate: Date(), // Different date
            voteAverage: 7.0, // Different rating
            posterURL: URL(string: "https://example.com/poster.jpg") // Different URL
        )

        let movie3 = Movie(
            id: 2, // Different ID
            title: "Movie 1",
            overview: "Overview 1",
            releaseDate: nil,
            voteAverage: 8.0,
            posterURL: nil
        )

        // Movies with same ID should be equal regardless of other properties
        #expect(movie1 == movie2)
        // Movies with different IDs should not be equal
        #expect(movie1 != movie3)
    }
}
