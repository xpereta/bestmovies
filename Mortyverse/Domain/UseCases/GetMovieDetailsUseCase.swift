protocol GetMovieDetailsUseCaseProtocol {
    func execute(movieId: Int) async throws -> MovieDetails
}

struct GetMovieDetailsUseCase: GetMovieDetailsUseCaseProtocol {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(movieId: Int) async throws -> MovieDetails {
        try await repository.fetchMovieDetails(movieId)
    }
}
