import Domain

class MovieRepositorySpyFetchMovies: MovieRepositoryType {
    var fetchMoviesCallCount = 0
    var lastPage: Int?
    var lastQuery: String?
    var moviesToReturn: [Movie] = []
    var hasMorePagesToReturn = false
    var errorToThrow: Error?

    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        fetchMoviesCallCount += 1
        lastPage = page
        lastQuery = query

        if let error = errorToThrow {
            throw error
        }

        return (movies: moviesToReturn, hasMorePages: hasMorePagesToReturn)
    }

    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails {
        fatalError("Not implemented")
    }

    func fetchReviews(movieId: Int) async throws -> [Review] {
        fatalError("Not implemented")
    }
}
