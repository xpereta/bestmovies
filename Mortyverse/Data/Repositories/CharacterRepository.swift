import Foundation

protocol CharacterRepositoryProvider {
    func fetchCharacters() async throws -> [Character]
}

final class CharacterRepository: CharacterRepositoryProvider {
    private let apiClient: RMAPIClient
    
    init(apiClient: RMAPIClient = RMAPIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchCharacters() async throws -> [Character] {
        let response: CharacterResponse = try await apiClient.fetch(.characters)
        let domainCharacters = CharacterDTOMapper.mapList(response.results)
        return domainCharacters
    }
}
