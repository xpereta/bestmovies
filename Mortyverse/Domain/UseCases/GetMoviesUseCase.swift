//struct PaginatedCharacters {
//    let characters: [Character]
//    let currentPage: Int
//    let hasMorePages: Bool
//}
//
//final class GetCharactersUseCase {
//    private let repository: CharacterRepositoryProvider
//    
//    init(repository: CharacterRepositoryProvider) {
//        self.repository = repository
//    }
//    
//    func execute(page: Int = 1, name: String?) async throws -> PaginatedCharacters {
//        let result = try await repository.fetchCharacters(page: page, name: name)
//        
//        return PaginatedCharacters(
//            characters: result.items,
//            currentPage: result.currentPage,
//            hasMorePages: result.hasMorePages
//        )
//    }
//}

enum MovieRepositoryError: Error {
    case notFound
}

struct GetMoviesUseCase {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }
    
    #warning("Keep a tuple or use a struct?")
    func execute(page: Int = 1, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        try await repository.fetchMovies(page: page, query: query)
    }
}
