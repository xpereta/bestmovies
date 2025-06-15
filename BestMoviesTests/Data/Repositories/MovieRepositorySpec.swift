@testable import BestMovies
import Foundation
import Networking
import Nimble
import Quick
import TMDBAPI

class MockTMDBAPIClient: TMDBAPI.ClientType {
    var movieResponseToReturn: TMDBAPI.DTO.MovieResponse?
    var movieDetailsToReturn: TMDBAPI.DTO.MovieDetails?
    var reviewsResponseToReturn: TMDBAPI.DTO.ReviewResponse?
    var errorToThrow: Error?

    var fetchMoviesCallCount = 0
    var lastPageRequested: Int?
    var lastQueryRequested: String?

    var fetchMovieDetailsCallCount = 0
    var fetchReviewsCallCount = 0

    var lastMovieIdRequested: Int?

    func fetchMovies(page: Int, query: String?) async throws -> TMDBAPI.DTO.MovieResponse {
        fetchMoviesCallCount += 1
        lastPageRequested = page
        lastQueryRequested = query

        if let error = errorToThrow {
            throw error
        }

        return movieResponseToReturn ?? TMDBAPI.DTO.MovieResponse(page: 1, results: [], totalPages: 1)
    }

    func fetchMovieDetails(_ id: Int) async throws -> TMDBAPI.DTO.MovieDetails {
        fetchMovieDetailsCallCount += 1
        lastMovieIdRequested = id

        if let error = errorToThrow {
            throw error
        }

        return movieDetailsToReturn ?? TMDBAPI.DTO.MovieDetails(
            id: id,
            title: "",
            overview: "",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "",
            voteAverage: 0,
            voteCount: 0,
            runtime: nil,
            genres: [],
            status: "",
            tagline: nil,
            budget: 0,
            revenue: 0,
            originalLanguage: "en"
        )
    }

    func fetchMovieReviews(movieId: Int) async throws -> TMDBAPI.DTO.ReviewResponse {
        fetchReviewsCallCount += 1

        if let error = errorToThrow {
            throw error
        }

        return reviewsResponseToReturn ?? TMDBAPI.DTO.ReviewResponse(results: [])
    }
}

class MovieRepositorySpec: AsyncSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("MovieRepository") {
            var sut: MovieRepository!
            var mockClient: MockTMDBAPIClient!
            var mockConfigurationProvider: ConfigurationProvider!

            beforeEach {
                mockClient = MockTMDBAPIClient()
                mockConfigurationProvider = MockConfigurationProvider()
                sut = MovieRepository(apiClient: mockClient, configurationProvider: mockConfigurationProvider)
            }

            // MARK: - fetchMovies Tests

            describe("fetchMovies") {
                context("when the request is successful") {
                    beforeEach {
                        mockClient.movieResponseToReturn = TMDBAPI.DTO.MovieResponse(
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

                        expect(mockClient.lastPageRequested) == 2
                        expect(mockClient.lastQueryRequested) == "test query"
                        expect(mockClient.fetchMoviesCallCount) == 1
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        mockClient.errorToThrow = NSError(domain: "test", code: -1)
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
                        mockClient.movieDetailsToReturn = TMDBAPI.DTO.MovieDetails(
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

                        expect(mockClient.lastMovieIdRequested) == 123
                        expect(mockClient.fetchMovieDetailsCallCount) == 1
                    }
                }

                context("when the movie is not found") {
                    beforeEach {
                        mockClient.errorToThrow = ApiProviderError.failed(statusCode: 404)
                    }

                    it("throws movieNotFound error") {
                        await expect {
                            try await sut.fetchMovieDetails(123)
                        }.to(throwError(MovieRepositoryError.movieNotFound(withId: 123)))
                    }
                }

                context("when another error occurs") {
                    beforeEach {
                        mockClient.errorToThrow = NSError(domain: "test", code: -1)
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
                        mockClient.reviewsResponseToReturn = TMDBAPI.DTO.ReviewResponse(
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

                        expect(mockClient.fetchReviewsCallCount) == 1
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        mockClient.errorToThrow = NSError(domain: "test", code: -1)
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
