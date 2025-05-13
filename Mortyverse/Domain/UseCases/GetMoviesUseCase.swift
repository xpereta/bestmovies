protocol GetMoviesUseCaseProtocol {
    func execute(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool)
}

struct GetMoviesUseCase: GetMoviesUseCaseProtocol {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(page: Int = 1, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        try await repository.fetchMovies(page: page, query: query)
    }
}
