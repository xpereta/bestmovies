import BestMoviesDomain
import Foundation
import Nimble
import Quick
import TMDBAPI
@testable import TMDBDataSource

class MovieMapperSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("MovieDTOMapper") {
            var configurationProvider: TestConfigurationProvider!

            beforeEach {
                configurationProvider = TestConfigurationProvider()
            }

            context("when mapping a single DTO") {
                context("with valid information") {
                    it("maps all properties correctly") {
                        let dto = TMDBAPI.DTO.Movie(
                            id: 1,
                            title: "The Matrix",
                            overview: "A computer hacker learns about the true nature of reality",
                            posterPath: "/path/to/poster.jpg",
                            releaseDate: "1999-03-31",
                            voteAverage: 8.7
                        )

                        let movie = MovieMapper(configurationProvider: configurationProvider).map(dto)

                        expect(movie.id).to(equal(1))
                        expect(movie.title).to(equal("The Matrix"))
                        expect(movie.overview).to(equal("A computer hacker learns about the true nature of reality"))
                        expect(movie.posterURL?.absoluteString).to(equal("https://image.tmdb.org/t/p/w200/path/to/poster.jpg"))
                        expect(movie.voteAverage).to(equal(8.7))

                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day], from: movie.releaseDate!)

                        expect(components.year).to(equal(1999))
                        expect(components.month).to(equal(3))
                        expect(components.day).to(equal(31))
                    }
                }

                context("with missing poster path") {
                    it("maps to nil posterURL") {
                        let dto = TMDBAPI.DTO.Movie(
                            id: 1,
                            title: "The Matrix",
                            overview: "A computer hacker learns about the true nature of reality",
                            posterPath: nil,
                            releaseDate: "1999-03-31",
                            voteAverage: 8.7
                        )

                        let movie = MovieMapper(configurationProvider: configurationProvider).map(dto)

                        expect(movie.posterURL).to(beNil())
                    }
                }

                context("with invalid date") {
                    it("returns nil as releaseDate") {
                        let dto = TMDBAPI.DTO.Movie(
                            id: 1,
                            title: "The Matrix",
                            overview: "A computer hacker learns about the true nature of reality",
                            posterPath: "/path/to/poster.jpg",
                            releaseDate: "15-15-2025",
                            voteAverage: 8.7
                        )

                        let movie = MovieMapper(configurationProvider: configurationProvider).map(dto)

                        expect(movie.releaseDate).to(beNil())
                    }
                }

                context("with non date") {
                    it("returns nil as releaseDate") {
                        let dto = TMDBAPI.DTO.Movie(
                            id: 1,
                            title: "The Matrix",
                            overview: "A computer hacker learns about the true nature of reality",
                            posterPath: "/path/to/poster.jpg",
                            releaseDate: "this-is-not-a-date",
                            voteAverage: 8.7
                        )

                        let movie = MovieMapper(configurationProvider: configurationProvider).map(dto)

                        expect(movie.releaseDate).to(beNil())
                    }
                }

                context("wihtout date date") {
                    it("returns nil as releaseDate") {
                        let dto = TMDBAPI.DTO.Movie(
                            id: 1,
                            title: "The Matrix",
                            overview: "A computer hacker learns about the true nature of reality",
                            posterPath: "/path/to/poster.jpg",
                            releaseDate: "",
                            voteAverage: 8.7
                        )

                        let movie = MovieMapper(configurationProvider: configurationProvider).map(dto)

                        expect(movie.releaseDate).to(beNil())
                    }
                }
            }

            context("when mapping multiple DTOs") {
                it("maps all DTOs correctly") {
                    let dtos = [
                        TMDBAPI.DTO.Movie(
                            id: 1,
                            title: "The Matrix",
                            overview: "First movie",
                            posterPath: "/path1.jpg",
                            releaseDate: "1999-03-31",
                            voteAverage: 8.7
                        ),
                        TMDBAPI.DTO.Movie(
                            id: 2,
                            title: "The Matrix Reloaded",
                            overview: "Second movie",
                            posterPath: "/path2.jpg",
                            releaseDate: "2003-05-15",
                            voteAverage: 7.2
                        )
                    ]

                    let movies = MovieMapper(configurationProvider: configurationProvider).mapList(dtos)

                    expect(movies).to(haveCount(2))
                    expect(movies[0].title).to(equal("The Matrix"))
                    expect(movies[0].posterURL?.absoluteString).to(equal("https://image.tmdb.org/t/p/w200/path1.jpg"))
                    expect(movies[1].title).to(equal("The Matrix Reloaded"))
                    expect(movies[1].posterURL?.absoluteString).to(equal("https://image.tmdb.org/t/p/w200/path2.jpg"))
                }

                it("returns empty array when given empty input") {
                    let movies = MovieMapper(configurationProvider: configurationProvider).mapList([])

                    expect(movies).to(beEmpty())
                }
            }

            context("Movie model equality") {
                it("considers two movies equal if they have the same id") {
                    let movie1 = Movie(
                        id: 1,
                        title: "The Matrix",
                        overview: "First version",
                        releaseDate: Date(),
                        voteAverage: 8.7,
                        posterURL: URL(string: "https://image.tmdb.org/t/p/w200/path1.jpg")
                    )

                    let movie2 = Movie(
                        id: 1,
                        title: "Another Matrix",
                        overview: "Another version",
                        releaseDate: Date().addingTimeInterval(10),
                        voteAverage: 9.0,
                        posterURL: URL(string: "https://image.tmdb.org/t/p/w200/path2.jpg")
                    )

                    expect(movie1).to(equal(movie2))
                }

                it("considers movies with different ids as not equal") {
                    let movie1 = Movie(
                        id: 1,
                        title: "The Matrix",
                        overview: "Overview",
                        releaseDate: Date(),
                        voteAverage: 9.0,
                        posterURL: URL(string: "https://image.tmdb.org/t/p/w200/path.jpg")
                    )

                    let movie2 = Movie(
                        id: 2,
                        title: "The Matrix",
                        overview: "Overview",
                        releaseDate: Date(),
                        voteAverage: 9.0,
                        posterURL: URL(string: "https://image.tmdb.org/t/p/w200/path.jpg")
                    )

                    expect(movie1).notTo(equal(movie2))
                }
            }
        }
    }
}
