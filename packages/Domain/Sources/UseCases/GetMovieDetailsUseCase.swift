import Foundation

public protocol GetMovieDetailsUseCaseType {
    func execute(movieId: Int) async throws -> MovieDetails
}

public struct GetMovieDetailsUseCase: GetMovieDetailsUseCaseType {
    private let repository: MovieRepositoryType

    public init(repository: MovieRepositoryType) {
        self.repository = repository
    }

    public func execute(movieId: Int) async throws -> MovieDetails {
        try await repository.fetchMovieDetails(movieId)
    }
}