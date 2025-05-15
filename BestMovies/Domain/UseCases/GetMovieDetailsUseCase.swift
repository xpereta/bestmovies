protocol GetMovieDetailsUseCaseType {
    func execute(movieId: Int) async throws -> MovieDetails
}

struct GetMovieDetailsUseCase: GetMovieDetailsUseCaseType {
    private let repository: MovieRepositoryType
    
    init(repository: MovieRepositoryType) {
        self.repository = repository
    }
    
    func execute(movieId: Int) async throws -> MovieDetails {
        try await repository.fetchMovieDetails(movieId)
    }
}
