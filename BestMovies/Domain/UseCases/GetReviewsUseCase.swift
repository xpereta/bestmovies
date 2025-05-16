protocol GetReviewsUseCaseType {
    func execute(movieId: Int) async throws -> [Review]
}

final class GetReviewsUseCase: GetReviewsUseCaseType {
    private let repository: MovieRepositoryType

    init(repository: MovieRepositoryType) {
        self.repository = repository
    }

    func execute(movieId: Int) async throws -> [Review] {
        try await repository.fetchReviews(movieId: movieId)
    }
}
