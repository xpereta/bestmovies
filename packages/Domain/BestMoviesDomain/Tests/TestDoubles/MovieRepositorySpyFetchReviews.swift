import BestMoviesDomain

class MockMovieRepositorySpyFetchReviews: MovieRepositoryType {
    var fetchReviewsCallCount = 0
    var lastMovieId: Int?
    var reviewsToReturn: [Review] = []
    var errorToThrow: Error?

    func fetchReviews(movieId: Int) async throws -> [Review] {
        fetchReviewsCallCount += 1
        lastMovieId = movieId

        if let error = errorToThrow {
            throw error
        }

        return reviewsToReturn
    }

    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        fatalError("Not implemented")
    }

    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails {
        fatalError("Not implemented")
    }
}
