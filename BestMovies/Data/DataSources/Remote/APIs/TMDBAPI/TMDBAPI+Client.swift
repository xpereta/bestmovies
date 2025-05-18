import Foundation
import Networking

extension TMDBAPI {
    protocol ClientType {
        func fetchMovies(page: Int, query: String?) async throws -> TMDBAPI.DTO.MovieResponse
        func fetchMovieDetails(_ id: Int) async throws -> TMDBAPI.DTO.MovieDetails
        func fetchMovieReviews(movieId: Int) async throws -> TMDBAPI.DTO.ReviewResponse
    }

    struct Client: ClientType {
        let apiProvider: ApiProvider
        let apiConfiguration: TMDBConfiguration

        func fetchMovies(page: Int, query: String?) async throws -> TMDBAPI.DTO.MovieResponse {
            let request: URLRequest

            if let query = query, !query.isEmpty {
                request = try TMDBAPI.Endpoint.searchMovies(query: query, page: page, configuration: apiConfiguration).makeURLRequest()
            } else {
                request = try TMDBAPI.Endpoint.topRated(page: page, configuration: apiConfiguration).makeURLRequest()
            }

            return try await apiProvider.performRequest(request, decodeTo: TMDBAPI.DTO.MovieResponse.self)
        }

        func fetchMovieDetails(_ id: Int) async throws -> TMDBAPI.DTO.MovieDetails {
            let request = try TMDBAPI.Endpoint.movie(id: id, configuration: apiConfiguration).makeURLRequest()
            let movie = try await apiProvider.performRequest(request, decodeTo: TMDBAPI.DTO.MovieDetails.self)

            return movie
        }

        func fetchMovieReviews(movieId: Int) async throws -> TMDBAPI.DTO.ReviewResponse {
            let request = try TMDBAPI.Endpoint.movieReviews(movieId: movieId, configuration: apiConfiguration).makeURLRequest()

            return try await apiProvider.performRequest(request, decodeTo: TMDBAPI.DTO.ReviewResponse.self)
        }
    }
}
