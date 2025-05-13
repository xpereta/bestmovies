struct GetMoviesUseCase {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    #warning("Keep a tuple or use a struct?")
    func execute(page: Int = 1, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        try await repository.fetchMovies(page: page, query: query)
    }
}
