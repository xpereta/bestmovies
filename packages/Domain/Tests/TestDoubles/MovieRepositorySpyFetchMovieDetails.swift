import Domain

class MoveRepositorySpyFetchMovieDetails: MovieRepositoryType {
    var fetchMovieDetailsCallCount = 0
    var lastMovieId: Int?
    var movieDetailsToReturn: MovieDetails?
    var errorToThrow: Error?

    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails {
        fetchMovieDetailsCallCount += 1
        lastMovieId = id

        if let error = errorToThrow {
            throw error
        }

        guard let movieDetails = movieDetailsToReturn else {
            throw MovieRepositoryError.movieNotFound(withId: id)
        }

        return movieDetails
    }

    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        fatalError("Not implemented")
    }

    func fetchReviews(movieId: Int) async throws -> [Review] {
        fatalError("Not implemented")
    }
}
