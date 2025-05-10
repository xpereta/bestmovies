struct PaginatedCharacters {
    let characters: [Character]
    let currentPage: Int
    let hasMorePages: Bool
}

final class GetCharactersUseCase {
    private let repository: CharacterRepositoryProvider
    
    init(repository: CharacterRepositoryProvider) {
        self.repository = repository
    }
    
    func execute(page: Int = 1, name: String?) async throws -> PaginatedCharacters {
        let result = try await repository.fetchCharacters(page: page, name: name)
        
        return PaginatedCharacters(
            characters: result.items,
            currentPage: result.currentPage,
            hasMorePages: result.hasMorePages
        )
    }
}
