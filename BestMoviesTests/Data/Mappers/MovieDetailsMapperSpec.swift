@testable import BestMovies
import Foundation
import Nimble
import Quick

class MovieDetailsMapperSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("MovieDetailsMapper") {
            context("when mapping a DTO") {
                context("with valid information") {
                    it("maps all properties correctly") {
                        let dto = TMDBAPI.DTO.MovieDetails(
                            id: 1,
                            title: "The Matrix",
                            overview: "A computer hacker learns about the true nature of reality",
                            posterPath: "/path/to/poster.jpg",
                            backdropPath: "/path/to/backdrop.jpg",
                            releaseDate: "1999-03-31",
                            voteAverage: 8.7,
                            voteCount: 15401,
                            runtime: 136,
                            genres: [
                                TMDBAPI.DTO.Genre(id: 28, name: "Action"),
                                TMDBAPI.DTO.Genre(id: 878, name: "Science Fiction")
                            ],
                            status: "Released",
                            tagline: "Welcome to the Real World",
                            budget: 63000000,
                            revenue: 463517383,
                            originalLanguage: "en"
                        )

                        let movieDetails = MovieDetailsMapper.map(dto)

                        expect(movieDetails.id).to(equal(1))
                        expect(movieDetails.title).to(equal("The Matrix"))
                        expect(movieDetails.overview).to(equal("A computer hacker learns about the true nature of reality"))
                        expect(movieDetails.posterPath).to(equal("/path/to/poster.jpg"))
                        expect(movieDetails.backdropPath).to(equal("/path/to/backdrop.jpg"))
                        expect(movieDetails.voteAverage).to(equal(8.7))
                        expect(movieDetails.voteCount).to(equal(15401))
                        expect(movieDetails.runtime).to(equal(136))
                        expect(movieDetails.status).to(equal("Released"))
                        expect(movieDetails.tagline).to(equal("Welcome to the Real World"))
                        expect(movieDetails.budget).to(equal(63000000))
                        expect(movieDetails.revenue).to(equal(463517383))
                        expect(movieDetails.originalLanguage).to(equal("en"))

                        // Date validation
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day], from: movieDetails.releaseDate!)
                        expect(components.year).to(equal(1999))
                        expect(components.month).to(equal(3))
                        expect(components.day).to(equal(31))

                        // Genres validation
                        expect(movieDetails.genres).to(haveCount(2))
                        expect(movieDetails.genres[0].id).to(equal(28))
                        expect(movieDetails.genres[0].name).to(equal("Action"))
                        expect(movieDetails.genres[1].id).to(equal(878))
                        expect(movieDetails.genres[1].name).to(equal("Science Fiction"))
                    }
                }

                context("with missing optional values") {
                    it("maps to nil for optional properties") {
                        let dto = TMDBAPI.DTO.MovieDetails(
                            id: 1,
                            title: "The Matrix",
                            overview: "Overview",
                            posterPath: nil,
                            backdropPath: nil,
                            releaseDate: "1999-03-31",
                            voteAverage: 8.7,
                            voteCount: 15401,
                            runtime: nil,
                            genres: [],
                            status: "Released",
                            tagline: nil,
                            budget: 0,
                            revenue: 0,
                            originalLanguage: "en"
                        )

                        let movieDetails = MovieDetailsMapper.map(dto)

                        expect(movieDetails.posterPath).to(beNil())
                        expect(movieDetails.backdropPath).to(beNil())
                        expect(movieDetails.posterURL).to(beNil())
                        expect(movieDetails.backdropURL).to(beNil())
                        expect(movieDetails.runtime).to(beNil())
                        expect(movieDetails.runtimeFormatted).to(beNil())
                        expect(movieDetails.tagline).to(beNil())
                    }
                }

                context("with runtime formatting") {
                    it("formats runtime correctly") {
                        let dto = TMDBAPI.DTO.MovieDetails(
                            id: 1,
                            title: "Test Movie",
                            overview: "Overview",
                            posterPath: nil,
                            backdropPath: nil,
                            releaseDate: "2024-01-01",
                            voteAverage: 7.0,
                            voteCount: 100,
                            runtime: 154,  // 2h 34m
                            genres: [],
                            status: "Released",
                            tagline: nil,
                            budget: 0,
                            revenue: 0,
                            originalLanguage: "en"
                        )

                        let movieDetails = MovieDetailsMapper.map(dto)
                        expect(movieDetails.runtimeFormatted).to(equal("2h 34m"))
                    }
                }
            }
        }
    }
}
