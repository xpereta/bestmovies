//import Foundation
//
//struct paginatedResult<T> {
//    let items: [T]
//    let currentPage: Int
//    let totalPages: Int
//    let hasMorePages: Bool
//}
//
//protocol CharacterRepositoryProvider {
//    func fetchCharacters(page: Int, name: String?) async throws -> paginatedResult<Character>
//    func fetchCharacter(id: Int) async throws -> Character
//}
//
//final class CharacterRepository: CharacterRepositoryProvider {
//    private let apiClient: RMAPIClient
//    
//    init(apiClient: RMAPIClient = RMAPIClient()) {
//        self.apiClient = apiClient
//    }
//    
//    func fetchCharacters(page: Int = 1, name: String? = nil) async throws -> paginatedResult<Character> {
//        print("Repository * Fetching characters - Page: \(page), Search: \(name ?? "none")")
//        let response: CharacterResponse = try await apiClient.fetch(.characters(page: page, name: name))
//        let domainCharacters = CharacterDTOMapper.mapList(response.results)
//        
//        return paginatedResult(
//            items: domainCharacters,
//            currentPage: page,
//            totalPages: response.info.pages,
//            hasMorePages: response.info.next != nil
//        )
//    }
//    
//    func fetchCharacter(id: Int) async throws -> Character {
//        print("Repository * Fetching character: \(id)")
//        let character: CharacterDTO = try await apiClient.fetch(.character(id: id))
//        let domainCharacter = CharacterDTOMapper.map(character)
//        return domainCharacter
//    }
//}
