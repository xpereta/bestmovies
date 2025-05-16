@testable import BestMovies
import Foundation
import Nimble
import Quick

class SpyApiProvider: ApiProvider {
    var dataToReturn: Data = Data()
    var responseToReturn: URLResponse = URLResponse()
    var errorToThrow: Error?

    var lastRequest: URLRequest?
    var executeCount = 0

    func performRequest(
        _ urlRequest: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (data: Data, urlResponse: URLResponse) {
        executeCount += 1
        lastRequest = urlRequest

        if let error = errorToThrow {
            throw error
        }

        return (dataToReturn, responseToReturn)
    }
}

class TMDBAPIClientSpec: AsyncSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("TMDBAPI.Client") {
            var sut: TMDBAPI.Client!
            var spyProvider: SpyApiProvider!
            var configuration: TMDBConfiguration!

            beforeEach {
                configuration = TMDBConfiguration(
                    baseURL: "https://api.test.com",
                    apiKey: "test-api-key"
                )
                spyProvider = SpyApiProvider()
                sut = TMDBAPI.Client(apiProvider: spyProvider, apiConfiguration: configuration)
            }

            context("fetchMovies") {
                let validResponse = """
                {
                    "page": 1,
                    "results": [
                        {
                            "id": 123,
                            "title": "Test Movie",
                            "overview": "Test Overview",
                            "poster_path": "/test.jpg",
                            "release_date": "1950-01-01",
                            "vote_average": 8.5
                        }
                    ],
                    "total_pages": 10
                }
                """

                context("when fetching top rated movies") {
                    beforeEach {
                        spyProvider.dataToReturn = Data(validResponse.utf8)
                    }

                    it("makes request with correct URL and parameters") {
                        _ = try await sut.fetchMovies(page: 1, query: nil)

                        let url = spyProvider.lastRequest?.url?.absoluteString
                        expect(url).to(contain("https://api.test.com/movie/top_rated"))
                        expect(url).to(contain("api_key=test-api-key"))
                        expect(url).to(contain("page=1"))
                    }

                    it("returns parsed movie response") {
                        let response = try await sut.fetchMovies(page: 1, query: nil)

                        expect(response.page) == 1
                        expect(response.totalPages) == 10
                        expect(response.results).to(haveCount(1))

                        let movie = response.results.first
                        expect(movie?.id) == 123
                        expect(movie?.title) == "Test Movie"
                        expect(movie?.overview) == "Test Overview"
                        expect(movie?.posterPath) == "/test.jpg"
                        expect(movie?.releaseDate) == "1950-01-01"
                        expect(movie?.voteAverage) == 8.5
                    }
                }

                context("when searching movies") {
                    beforeEach {
                        spyProvider.dataToReturn = Data(validResponse.utf8)
                    }

                    it("makes request with correct search URL and parameters") {
                        _ = try await sut.fetchMovies(page: 1, query: "matrix")

                        let url = spyProvider.lastRequest?.url?.absoluteString
                        expect(url).to(contain("https://api.test.com/search/movie"))
                        expect(url).to(contain("api_key=test-api-key"))
                        expect(url).to(contain("query=matrix"))
                        expect(url).to(contain("page=1"))
                    }
                }

                context("when api provider throws error") {
                    beforeEach {
                        spyProvider.errorToThrow = NSError(domain: "test", code: -1)
                    }

                    it("propagates the error") {
                        await expect { try await sut.fetchMovies(page: 1, query: nil) }.to(throwError())
                    }
                }
            }

            context("fetchMovieDetails") {
                let validResponse = """
                {
                    "id": 123,
                    "title": "Test Movie",
                    "overview": "Test Overview",
                    "poster_path": "/test.jpg",
                    "backdrop_path": "/backdrop.jpg",
                    "release_date": "1950-01-01",
                    "vote_average": 8.5,
                    "vote_count": 100,
                    "runtime": 120,
                    "genres": [
                        {"id": 28, "name": "Action"}
                    ],
                    "status": "Released",
                    "tagline": "Test Tagline",
                    "budget": 1000000,
                    "revenue": 5000000,
                    "original_language": "en"
                }
                """

                context("when fetching movie details") {
                    beforeEach {
                        spyProvider.dataToReturn = Data(validResponse.utf8)
                    }

                    it("makes request with correct URL and parameters") {
                        _ = try await sut.fetchMovieDetails(123)

                        let url = spyProvider.lastRequest?.url?.absoluteString
                        expect(url).to(contain("https://api.test.com/movie/123"))
                        expect(url).to(contain("api_key=test-api-key"))
                    }

                    it("returns parsed movie details") {
                        let movie = try await sut.fetchMovieDetails(123)

                        expect(movie.id) == 123
                        expect(movie.title) == "Test Movie"
                        expect(movie.overview) == "Test Overview"
                        expect(movie.posterPath) == "/test.jpg"
                        expect(movie.backdropPath) == "/backdrop.jpg"
                        expect(movie.releaseDate) == "1950-01-01"
                        expect(movie.voteAverage) == 8.5
                        expect(movie.voteCount) == 100
                        expect(movie.runtime) == 120
                        expect(movie.genres).to(haveCount(1))
                        expect(movie.status) == "Released"
                        expect(movie.tagline) == "Test Tagline"
                        expect(movie.budget) == 1000000
                        expect(movie.revenue) == 5000000
                        expect(movie.originalLanguage) == "en"
                    }
                }

                context("when api provider throws error") {
                    beforeEach {
                        spyProvider.errorToThrow = NSError(domain: "test", code: -1)
                    }

                    it("propagates the error") {
                        await expect { try await sut.fetchMovieDetails(123) }.to(throwError())
                    }
                }
            }

            context("fetchMovieReviews") {
                let validResponse = """
                {
                    "results": [
                        {
                            "id": "1",
                            "author": "John Doe",
                            "content": "A good movie",
                            "created_at": "2021-06-23T15:58:13.726Z",
                            "author_details": {
                                "name": "John",
                                "avatar_path": "/avatar.jpg",
                                "rating": 8.5
                            }
                        },
                        {
                            "id": "2",
                            "author": "Jane Smith",
                            "content": "Amazing!",
                            "created_at": "2021-09-18T19:56:48.348Z"
                        }
                    ]
                }
                """

                let invalidResponse = """
                    Clearly not a JSON response
                """

                let undecodableResponse = """
                {
                    "results": [
                        {
                            "id": "1",
                            "author": "John Doe",
                            "content": "A good movie",
                            "created_at": "2021-06-23T15:58:13.726Z",
                            "author_details": {
                                "name": "John",
                                "avatar_path": "/avatar.jpg",
                                "rating": "Clearly not a double"
                            }
                        }
                    ]
                }
                """

                context("when fetching movie reviews") {
                    beforeEach {
                        spyProvider.dataToReturn = Data(validResponse.utf8)
                    }

                    it("makes request with correct URL and parameters") {
                        _ = try await sut.fetchMovieReviews(movieId: 123)

                        let url = spyProvider.lastRequest?.url?.absoluteString
                        expect(url).to(contain("https://api.test.com/movie/123/reviews"))
                        expect(url).to(contain("api_key=test-api-key"))
                    }

                    it("returns parsed review response") {
                        let response = try await sut.fetchMovieReviews(movieId: 123)

                        expect(response.results).to(haveCount(2))
                        let review = response.results.first
                        expect(review?.id) == "1"
                        expect(review?.author) == "John Doe"
                        expect(review?.content) == "A good movie"
                        expect(review?.createdAt) == "2021-06-23T15:58:13.726Z"
                        expect(review?.authorDetails?.name) == "John"
                        expect(review?.authorDetails?.avatarPath) == "/avatar.jpg"
                        expect(review?.authorDetails?.rating) == 8.5
                    }
                }

                context("when receiving invalid response") {
                    beforeEach {
                        spyProvider.dataToReturn = Data(invalidResponse.utf8)
                    }

                    it("in throws an error") {
                        await expect {
                            try await sut.fetchMovieReviews(movieId: 123)
                        }.to(throwError())
                    }
                }

                context("when receiving response that is not decodable") {
                    beforeEach {
                        spyProvider.dataToReturn = Data(undecodableResponse.utf8)
                    }

                    it("in throws an error") {
                        await expect {
                            try await sut.fetchMovieReviews(movieId: 123)
                        }.to(throwError(ApiProviderError.decodingFailed.self))
                    }
                }

                context("when api provider throws any another error") {
                    beforeEach {
                        spyProvider.errorToThrow = NSError(domain: "test", code: -1)
                    }

                    it("propagates the error") {
                        await expect {
                            try await sut.fetchMovieReviews(movieId: 123)
                        }.to(throwError())
                    }
                }
            }
        }
    }
}
