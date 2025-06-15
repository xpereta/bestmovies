import Foundation

public protocol GetReviewsUseCaseType {
    func execute(movieId: Int) async throws -> [Review]
}

public final class GetReviewsUseCase: GetReviewsUseCaseType {
    private let repository: MovieRepositoryType

    public init(repository: MovieRepositoryType) {
        self.repository = repository
    }

    public func execute(movieId: Int) async throws -> [Review] {
        try await repository.fetchReviews(movieId: movieId)
    }
}