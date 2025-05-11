struct GetMovieDetailsUseCase {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }
    
    #warning("Keep a tuple or use a struct?")
    func execute(movieId: Int) async throws -> MovieDetails {
        try await repository.fetchMovieDetails(movieId)
    }
}
