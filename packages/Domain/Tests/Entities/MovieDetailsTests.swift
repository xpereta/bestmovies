@testable import Domain
import Foundation
import Testing

final class MovieDetailsTests {

    @Test("MovieDetails initialization with all properties")
    func testMovieDetailsInitialization() {
        let date = Date()
        let posterURL = URL(string: "https://example.com/poster.jpg")
        let backdropURL = URL(string: "https://example.com/backdrop.jpg")
        let genres = [Genre(id: 1, name: "Action"), Genre(id: 2, name: "Drama")]

        let movieDetails = MovieDetails(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            releaseDate: date,
            voteAverage: 8.5,
            voteCount: 1000,
            runtime: 120,
            genres: genres,
            status: "Released",
            tagline: "Test Tagline",
            budget: 1000000,
            revenue: 5000000,
            originalLanguage: "en",
            posterURL: posterURL,
            backdropURL: backdropURL
        )

        #expect(movieDetails.id == 1)
        #expect(movieDetails.title == "Test Movie")
        #expect(movieDetails.overview == "Test Overview")
        #expect(movieDetails.releaseDate == date)
        #expect(movieDetails.voteAverage == 8.5)
        #expect(movieDetails.voteCount == 1000)
        #expect(movieDetails.runtime == 120)
        #expect(movieDetails.genres == genres)
        #expect(movieDetails.status == "Released")
        #expect(movieDetails.tagline == "Test Tagline")
        #expect(movieDetails.budget == 1000000)
        #expect(movieDetails.revenue == 5000000)
        #expect(movieDetails.originalLanguage == "en")
        #expect(movieDetails.posterURL == posterURL)
        #expect(movieDetails.backdropURL == backdropURL)
    }

    @Test("MovieDetails initialization with nil values")
    func testMovieDetailsInitializationWithNilValues() {
        let movieDetails = MovieDetails(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            releaseDate: nil,
            voteAverage: 8.5,
            voteCount: 1000,
            runtime: nil,
            genres: [],
            status: "Released",
            tagline: nil,
            budget: 1000000,
            revenue: 5000000,
            originalLanguage: "en",
            posterURL: nil,
            backdropURL: nil
        )

        #expect(movieDetails.id == 1)
        #expect(movieDetails.title == "Test Movie")
        #expect(movieDetails.overview == "Test Overview")
        #expect(movieDetails.releaseDate == nil)
        #expect(movieDetails.runtime == nil)
        #expect(movieDetails.genres.isEmpty)
        #expect(movieDetails.tagline == nil)
        #expect(movieDetails.posterURL == nil)
        #expect(movieDetails.backdropURL == nil)
    }

    @Test("MovieDetails runtime formatting")
    func testRuntimeFormatting() {
        let movieDetails1 = MovieDetails(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            releaseDate: nil,
            voteAverage: 8.5,
            voteCount: 1000,
            runtime: 90,
            genres: [],
            status: "Released",
            tagline: nil,
            budget: 1000000,
            revenue: 5000000,
            originalLanguage: "en",
            posterURL: nil,
            backdropURL: nil
        )

        let movieDetails2 = MovieDetails(
            id: 2,
            title: "Test Movie 2",
            overview: "Test Overview",
            releaseDate: nil,
            voteAverage: 8.5,
            voteCount: 1000,
            runtime: 150,
            genres: [],
            status: "Released",
            tagline: nil,
            budget: 1000000,
            revenue: 5000000,
            originalLanguage: "en",
            posterURL: nil,
            backdropURL: nil
        )

        let movieDetails3 = MovieDetails(
            id: 3,
            title: "Test Movie 3",
            overview: "Test Overview",
            releaseDate: nil,
            voteAverage: 8.5,
            voteCount: 1000,
            runtime: nil,
            genres: [],
            status: "Released",
            tagline: nil,
            budget: 1000000,
            revenue: 5000000,
            originalLanguage: "en",
            posterURL: nil,
            backdropURL: nil
        )

        #expect(movieDetails1.runtimeFormatted == "1h 30m")
        #expect(movieDetails2.runtimeFormatted == "2h 30m")
        #expect(movieDetails3.runtimeFormatted == nil)
    }

    @Test("MovieDetails equality comparison")
    func testMovieDetailsEquality() {
        let movieDetails1 = MovieDetails(
            id: 1,
            title: "Movie 1",
            overview: "Overview 1",
            releaseDate: nil,
            voteAverage: 8.0,
            voteCount: 1000,
            runtime: 120,
            genres: [],
            status: "Released",
            tagline: nil,
            budget: 1000000,
            revenue: 5000000,
            originalLanguage: "en",
            posterURL: nil,
            backdropURL: nil
        )

        let movieDetails2 = MovieDetails(
            id: 1,
            title: "Movie 2", // Different title
            overview: "Overview 2", // Different overview
            releaseDate: Date(), // Different date
            voteAverage: 7.0, // Different rating
            voteCount: 2000, // Different vote count
            runtime: 150, // Different runtime
            genres: [Genre(id: 1, name: "Action")], // Different genres
            status: "Post Production", // Different status
            tagline: "New Tagline", // Different tagline
            budget: 2000000, // Different budget
            revenue: 6000000, // Different revenue
            originalLanguage: "fr", // Different language
            posterURL: URL(string: "https://example.com/poster.jpg"), // Different poster
            backdropURL: URL(string: "https://example.com/backdrop.jpg") // Different backdrop
        )

        let movieDetails3 = MovieDetails(
            id: 2, // Different ID
            title: "Movie 1",
            overview: "Overview 1",
            releaseDate: nil,
            voteAverage: 8.0,
            voteCount: 1000,
            runtime: 120,
            genres: [],
            status: "Released",
            tagline: nil,
            budget: 1000000,
            revenue: 5000000,
            originalLanguage: "en",
            posterURL: nil,
            backdropURL: nil
        )

        // Movies with same ID should be equal regardless of other properties
        #expect(movieDetails1 == movieDetails2)
        // Movies with different IDs should not be equal
        #expect(movieDetails1 != movieDetails3)
    }
}
