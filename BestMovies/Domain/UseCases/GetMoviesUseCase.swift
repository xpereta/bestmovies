protocol GetMoviesUseCaseType {
    func execute(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool)
}

struct GetMoviesUseCase: GetMoviesUseCaseType {
    private let repository: MovieRepositoryType
    
    init(repository: MovieRepositoryType) {
        self.repository = repository
    }
    
    func execute(page: Int = 1, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        try await repository.fetchMovies(page: page, query: query)
    }
}
