import Foundation

struct paginatedResult<T> {
    let items: [T]
    let currentPage: Int
    let totalPages: Int
    let hasMorePages: Bool
}

protocol CharacterRepositoryProvider {
    func fetchCharacters(page: Int) async throws -> paginatedResult<Character>
}

final class CharacterRepository: CharacterRepositoryProvider {
    private let apiClient: RMAPIClient
    
    init(apiClient: RMAPIClient = RMAPIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchCharacters(page: Int = 1) async throws -> paginatedResult<Character> {
        print("Repository * Fetching characters - Page: \(page)")
        let response: CharacterResponse = try await apiClient.fetch(.characters(page: 1))
        let domainCharacters = CharacterDTOMapper.mapList(response.results)
        
        return paginatedResult(
            items: domainCharacters,
            currentPage: page,
            totalPages: response.info.pages,
            hasMorePages: response.info.next != nil
        )
    }
}
