import Domain
import Foundation
import Networking
import TMDBAPI

struct MovieRepository: MovieRepositoryType {
    let apiClient: TMDBAPI.ClientType
    private let configurationProvider: ConfigurationProvider

    init(apiClient: TMDBAPI.ClientType, configurationProvider: ConfigurationProvider) {
        self.apiClient = apiClient
        self.configurationProvider = configurationProvider
    }

    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        let response = try await apiClient.fetchMovies(page: page, query: query)

        let movies = MovieMapper(configurationProvider: configurationProvider).mapList(response.results)
        let hasMorePages = response.page < response.totalPages

        return (movies: movies, hasMorePages: hasMorePages)
    }

    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails {
        do {
            let response = try await apiClient.fetchMovieDetails(id)

            return MovieDetailsMapper(configurationProvider: configurationProvider).map(response)
        } catch TMDBAPI.APIError.notFound {
            throw MovieRepositoryError.movieNotFound(withId: id)
        }
    }

    func fetchReviews(movieId: Int) async throws -> [Review] {
        let response = try await apiClient.fetchMovieReviews(movieId: movieId)

        let reviews = ReviewMapper(configurationProvider: configurationProvider).mapList(response.results)

        return reviews
    }
}
