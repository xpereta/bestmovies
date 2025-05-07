final class GetCharactersUseCase {
    private let repository: CharacterRepositoryProvider
    
    init(repository: CharacterRepositoryProvider) {
        self.repository = repository
    }
    
    func execute() async throws -> [Character] {
        try await repository.fetchCharacters()
    }
}
