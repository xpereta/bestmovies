import Foundation

public protocol MovieRepositoryType {
    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool)
    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails
    func fetchReviews(movieId: Int) async throws -> [Review]
}
