import Foundation

public protocol GetMoviesUseCaseType {
    func execute(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool)
}

public struct GetMoviesUseCase: GetMoviesUseCaseType {
    private let repository: MovieRepositoryType

    public init(repository: MovieRepositoryType) {
        self.repository = repository
    }

    public func execute(page: Int = 1, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        try await repository.fetchMovies(page: page, query: query)
    }
}
