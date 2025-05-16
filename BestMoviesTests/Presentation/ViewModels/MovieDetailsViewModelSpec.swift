@testable import BestMovies
import Foundation
import Nimble
import Quick

class SpyGetMovieDetailsUseCase: GetMovieDetailsUseCaseType {
    var movieToReturn: MovieDetails?
    var errorToThrow: Error?
    var executeCallCount = 0
    var executeWasCalled: Bool {
        executeCallCount > 0
    }

    var movieIdPassed: Int?

    func execute(movieId: Int) async throws -> MovieDetails {
        executeCallCount += 1
        movieIdPassed = movieId

        if let error = errorToThrow {
            throw error
        }

        if let movie = movieToReturn {
            return movie
        }

        throw NSError(domain: "Test", code: -1)
    }
}

class MovieDetailViewModelSpec: AsyncSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("MovieDetailViewModel") {
            var sut: MovieDetailViewModel!
            var spyGetMovieDetailsUseCase: SpyGetMovieDetailsUseCase!
            var spyGetReviewsUseCase: SpyGetMovieReviewsUseCase!
            var movie: MovieDetails!
            var reviews: [Review]!

            beforeEach {
                spyGetMovieDetailsUseCase = SpyGetMovieDetailsUseCase()
                movie = MovieDetails(
                    id: 123,
                    title: "Test Movie",
                    overview: "Test Overview",
                    posterPath: "/test.jpg",
                    backdropPath: "/backdrop.jpg",
                    releaseDate: Date(),
                    voteAverage: 8.5,
                    voteCount: 100,
                    runtime: 120,
                    genres: [],
                    status: "Released",
                    tagline: "Test Tagline",
                    budget: 1000000,
                    revenue: 5000000,
                    originalLanguage: "en"
                )
                reviews = [
                    Review(
                        id: "1",
                        author: "John Doe",
                        content: "This is a review",
                        createdAt: Date(),
                        authorDetails: Review.AuthorDetails(
                            name: "John Doe",
                            avatarPath: "/utEXl2EDiXBK6f41wCLsvprvMg4.jpg",
                            rating: 5.5)
                    ),
                    Review(
                        id: "2",
                        author: "Jane Doe",
                        content: "This is another review",
                        createdAt: Date(),
                        authorDetails: Review.AuthorDetails(
                            name: "Jane Doe",
                            avatarPath: "/invalid.jpg",
                            rating: 7.4)
                    )
                ]

                spyGetReviewsUseCase = SpyGetMovieReviewsUseCase()

                sut = await MovieDetailViewModel(movieId: 123, getMovieDetailsUseCase: spyGetMovieDetailsUseCase, getReviewsUseCase: spyGetReviewsUseCase)
            }

            context("initial state") {
                it("starts in idle state") { @MainActor in
                    expect(sut.state).to(equal(.idle))
                }
            }

            context("when loading a movie") {
                context("with successful response") {
                    beforeEach {
                        spyGetMovieDetailsUseCase.movieToReturn = movie
                    }

                    it("changes the state from idle, to loading, to loaded, with the correct movie") { @MainActor in
                        expect(sut.state).to(equal(.idle))

                        sut.loadMovie()

                        expect(sut.state).to(equal(.loading))

                        await expect(sut.state).toEventually(equal(.loaded(spyGetMovieDetailsUseCase.movieToReturn!, [])))

                        await expect(sut.state).toEventually(equal(.loaded(movie, [])))
                    }

                    it("calls the use case with the correct movie id") { @MainActor in
                        sut.loadMovie()
                        await expect(spyGetMovieDetailsUseCase.executeWasCalled).toEventually(beTrue())
                        await expect(spyGetMovieDetailsUseCase.movieIdPassed).toEventually(equal(123))
                    }
                }

                context("that has reviews") {
                    beforeEach {
                        spyGetMovieDetailsUseCase.movieToReturn = movie
                        spyGetReviewsUseCase.reviewsToReturn = reviews
                    }

                    it("loads the movie and the reviews") { @MainActor in
                        sut.loadMovie()

                        await expect(sut.state).toEventually(equal(.loaded(movie, reviews)))
                    }
                }

                context("that does not have reviews") {
                    beforeEach {
                        spyGetMovieDetailsUseCase.movieToReturn = movie
                        spyGetReviewsUseCase.reviewsToReturn = []
                    }

                    it("loads the movie but the reviews are empty") { @MainActor in
                        sut.loadMovie()

                        await expect(sut.state).toEventually(equal(.loaded(movie, [])))
                    }
                }

                context("with error response") {
                    beforeEach {
                        spyGetMovieDetailsUseCase.errorToThrow = MovieRepositoryError.movieNotFound(withId: 123)
                    }

                    it("changes state from idle, to loading, to error") { @MainActor in
                        expect(sut.state).to(equal(.idle))

                        sut.loadMovie()

                        expect(sut.state).to(equal(.loading))

                        await expect(sut.state).toEventually(equal(.error("Failed to load movie details: Movie not found with id 123.")))
                    }
                }
            }
        }
    }
}
