import Foundation

enum MovieRepositoryError: LocalizedError {
    case movieNotFound(withId: Int)

    var errorDescription: String? {
        switch self {
        case .movieNotFound(let withId):
            return "Movie not found with id \(withId)."
        }
    }
}

protocol MovieRepositoryType {
    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool)
    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails
    func fetchReviews(movieId: Int) async throws -> [Review]
}

struct MovieRepository: MovieRepositoryType {
    let apiClient: TMDBAPI.ClientType

    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        let response = try await apiClient.fetchMovies(page: page, query: query)

        let movies = MovieMapper.mapList(response.results)
        let hasMorePages = response.page < response.totalPages

        return (movies: movies, hasMorePages: hasMorePages)
    }

    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails {
        do {
            let response = try await apiClient.fetchMovieDetails(id)

            return MovieDetailsMapper.map(response)
        } catch ApiProviderError.failed(statusCode: 404) {
            throw MovieRepositoryError.movieNotFound(withId: id)
        }
    }

    func fetchReviews(movieId: Int) async throws -> [Review] {
        let response = try await apiClient.fetchMovieReviews(movieId: movieId)

        let reviews = ReviewMapper.mapList(response.results)

        return reviews
    }
}
