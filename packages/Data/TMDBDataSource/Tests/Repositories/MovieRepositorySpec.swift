import BestMoviesDomain
import Foundation
import Networking
import Nimble
import Quick
import TMDBAPI
@testable import TMDBDataSource

class MovieRepositorySpec: AsyncSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("MovieRepository") {
            var sut: MovieRepository!
            var spyClient: TMDBAPIClientSpy!
            var mockConfigurationProvider: ConfigurationProvider!

            beforeEach {
                spyClient = TMDBAPIClientSpy()
                mockConfigurationProvider = TestConfigurationProvider()
                sut = MovieRepository(apiClient: spyClient, configurationProvider: mockConfigurationProvider)
            }

            // MARK: - fetchMovies Tests

            describe("fetchMovies") {
                context("when the request is successful") {
                    beforeEach {
                        spyClient.movieResponseToReturn = TMDBAPI.DTO.MovieResponse(
                            page: 1,
                            results: [
                                .init(
                                    id: 1,
                                    title: "Test Movie",
                                    overview: "Test Overview",
                                    posterPath: "/test.jpg",
                                    releaseDate: "2024-01-01",
                                    voteAverage: 8.5
                                )
                            ],
                            totalPages: 2
                        )
                    }

                    it("returns mapped movies and correct hasMorePages flag") {
                        let result = try? await sut.fetchMovies(page: 1, query: nil)

                        expect(result?.movies.count) == 1
                        expect(result?.movies.first?.title) == "Test Movie"
                        expect(result?.hasMorePages) == true
                    }

                    it("passes the correct parameters to the client") {
                        _ = try? await sut.fetchMovies(page: 2, query: "test query")

                        expect(spyClient.lastPageRequested) == 2
                        expect(spyClient.lastQueryRequested) == "test query"
                        expect(spyClient.fetchMoviesCallCount) == 1
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        spyClient.errorToThrow = NSError(domain: "test", code: -1)
                    }

                    it("propagates the error") {
                        await expect {
                            try await sut.fetchMovies(page: 1, query: nil)
                        }.to(throwError())
                    }
                }
            }

            // MARK: - fetchMovieDetails Tests

            describe("fetchMovieDetails") {
                context("when the request is successful") {
                    beforeEach {
                        spyClient.movieDetailsToReturn = TMDBAPI.DTO.MovieDetails(
                            id: 1,
                            title: "Test Movie",
                            overview: "Test Overview",
                            posterPath: "/test.jpg",
                            backdropPath: "/backdrop.jpg",
                            releaseDate: "2024-01-01",
                            voteAverage: 8.5,
                            voteCount: 100,
                            runtime: 120,
                            genres: [.init(id: 1, name: "Action")],
                            status: "Released",
                            tagline: "Test Tagline",
                            budget: 1000000,
                            revenue: 5000000,
                            originalLanguage: "en"
                        )
                    }

                    it("returns mapped movie details") {
                        let result = try? await sut.fetchMovieDetails(1)

                        expect(result?.id) == 1
                        expect(result?.title) == "Test Movie"
                        expect(result?.genres.count) == 1
                        expect(result?.genres.first?.name) == "Action"
                    }

                    it("passes the correct movie id to the client") {
                        _ = try? await sut.fetchMovieDetails(123)

                        expect(spyClient.lastMovieIdRequested) == 123
                        expect(spyClient.fetchMovieDetailsCallCount) == 1
                    }
                }

                context("when the movie is not found") {
                    beforeEach {
                        spyClient.errorToThrow = ApiProviderError.failed(statusCode: 404)
                    }

                    it("throws movieNotFound error") {
                        await expect {
                            try await sut.fetchMovieDetails(123)
                        }.to(throwError(MovieRepositoryError.movieNotFound(withId: 123)))
                    }
                }

                context("when another error occurs") {
                    beforeEach {
                        spyClient.errorToThrow = NSError(domain: "test", code: -1)
                    }

                    it("propagates the error") {
                        await expect {
                            try await sut.fetchMovieDetails(123)
                        }.to(throwError())
                    }
                }
            }

            // MARK: - fetchMovieReviews Tests

            describe("fetchMovieReviews") {
                context("when the request is successful") {
                    beforeEach {
                        spyClient.reviewsResponseToReturn = TMDBAPI.DTO.ReviewResponse(
                            results: [
                                .init(
                                    id: "123",
                                    author: "John Doe",
                                    content: "Great movie!",
                                    createdAt: "2024-01-15",
                                    authorDetails: .init(
                                        name: "John Doe",
                                        avatarPath: "/avatar.jpg",
                                        rating: 8.5
                                    )
                                ),
                                .init(
                                    id: "review2",
                                    author: "Jane Smith",
                                    content: "Amazing!",
                                    createdAt: "2024-01-16",
                                    authorDetails: nil
                                )
                            ]
                        )
                    }

                    it("returns mapped reviews") {
                        let reviews = try? await sut.fetchReviews(movieId: 123)

                        expect(reviews?.count) == 2

                        let firstReview = reviews?.first
                        expect(firstReview?.id) == "123"
                        expect(firstReview?.author) == "John Doe"
                        expect(firstReview?.content) == "Great movie!"
                        expect(firstReview?.authorDetails?.rating) == 8.5

                        let secondReview = reviews?.last
                        expect(secondReview?.id) == "review2"
                        expect(secondReview?.author) == "Jane Smith"
                        expect(secondReview?.authorDetails).to(beNil())
                    }

                    it("makes the correct API call") {
                        _ = try? await sut.fetchReviews(movieId: 123)

                        expect(spyClient.fetchReviewsCallCount) == 1
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        spyClient.errorToThrow = NSError(domain: "test", code: -1)
                    }

                    it("propagates the error") {
                        await expect {
                            try await sut.fetchReviews(movieId: 123)
                        }.to(throwError())
                    }
                }
            }
        }
    }
}
