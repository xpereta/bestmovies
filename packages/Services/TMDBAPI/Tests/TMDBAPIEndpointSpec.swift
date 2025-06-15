import Foundation
import Networking
import Nimble
import Quick
@testable import TMDBAPI

class TMDBAPIEndpointSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("TMDBAPI.Endpoint") {
            let configuration = TMDBConfiguration(
                baseURL: "https://api.themoviedb.org/3",
                apiKey: "test_api_key"
            )

            context("baseURL") {
                it("returns the configured base URL") {
                    let endpoints: [TMDBAPI.Endpoint] = [
                        .topRated(page: 1, configuration: configuration),
                        .searchMovies(query: "test", page: 1, configuration: configuration),
                        .movie(id: 123, configuration: configuration),
                        .movieReviews(movieId: 123, configuration: configuration)
                    ]

                    endpoints.forEach { endpoint in
                        expect(endpoint.baseURL) == configuration.baseURL
                    }
                }
            }

            context("path") {
                it("returns the correct path for topRated") {
                    let endpoint = TMDBAPI.Endpoint.topRated(page: 1, configuration: configuration)
                    expect(endpoint.path) == "/movie/top_rated"
                }

                it("returns the correct path for searchMovies") {
                    let endpoint = TMDBAPI.Endpoint.searchMovies(query: "test", page: 1, configuration: configuration)
                    expect(endpoint.path) == "/search/movie"
                }

                it("returns the correct path for movie") {
                    let endpoint = TMDBAPI.Endpoint.movie(id: 123, configuration: configuration)
                    expect(endpoint.path) == "/movie/123"
                }

                it("returns the correct path for movieReviews") {
                    let endpoint = TMDBAPI.Endpoint.movieReviews(movieId: 123, configuration: configuration)
                    expect(endpoint.path) == "/movie/123/reviews"
                }
            }

            context("queryItems") {
                it("includes the api_key in all endpoints") {
                    let endpoints: [TMDBAPI.Endpoint] = [
                        .topRated(page: 1, configuration: configuration),
                        .searchMovies(query: "test", page: 1, configuration: configuration),
                        .movie(id: 123, configuration: configuration),
                        .movieReviews(movieId: 123, configuration: configuration)
                    ]

                    endpoints.forEach { endpoint in
                        expect(endpoint.queryItems).to(
                            containElementSatisfying { item in
                                item.name == "api_key" && item.value == configuration.apiKey
                            }
                        )
                    }
                }

                it("includes the page parameter for topRated") {
                    let endpoint = TMDBAPI.Endpoint.topRated(page: 2, configuration: configuration)
                    expect(endpoint.queryItems).to(
                        containElementSatisfying { item in
                            item.name == "page" && item.value == "2"
                        }
                    )
                }

                it("includes the query and page parameters for searchMovies") {
                    let endpoint = TMDBAPI.Endpoint.searchMovies(
                        query: "Matrix",
                        page: 3,
                        configuration: configuration
                    )
                    expect(endpoint.queryItems).to(
                        containElementSatisfying { item in
                            item.name == "query" && item.value == "Matrix"
                        }
                    )
                    expect(endpoint.queryItems).to(
                        containElementSatisfying { item in
                            item.name == "page" && item.value == "3"
                        }
                    )
                }

                it("just includes the api_key for movie endpoint") {
                    let endpoint = TMDBAPI.Endpoint.movie(id: 123, configuration: configuration)
                    expect(endpoint.queryItems.count) == 1
                    expect(endpoint.queryItems.first?.name) == "api_key"
                    expect(endpoint.queryItems.first?.value) == configuration.apiKey
                }
            }

            context("URL construction") {
                it("constructs valid URLs for all endpoints") {
                    let endpoints: [(TMDBAPI.Endpoint, String)] = [
                        (.topRated(page: 1, configuration: configuration),
                         "https://api.themoviedb.org/3/movie/top_rated"),
                        (.searchMovies(query: "test", page: 1, configuration: configuration),
                         "https://api.themoviedb.org/3/search/movie"),
                        (.movie(id: 123, configuration: configuration),
                         "https://api.themoviedb.org/3/movie/123"),
                        (.movieReviews(movieId: 123, configuration: configuration),
                         "https://api.themoviedb.org/3/movie/123/reviews")
                    ]

                    endpoints.forEach { endpoint, expectedURLPrefix in
                        let url = endpoint.baseURL.appending(endpoint.path)
                        var urlComponents = URLComponents(string: url)
                        urlComponents?.queryItems = endpoint.queryItems

                        expect(urlComponents?.url).toNot(beNil())
                        expect(urlComponents?.url?.absoluteString.hasPrefix(expectedURLPrefix)) == true
                    }
                }
            }
        }
    }
}
