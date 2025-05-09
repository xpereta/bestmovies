import Foundation
import Combine

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(Character)
        case error(String)
    }
    
    @Published private(set) var state: State = .loading
    
    private let repository: CharacterRepositoryProvider
    private let characterId: Int
    
    init(characterId: Int, repository: CharacterRepositoryProvider = CharacterRepository()) {
        self.characterId = characterId
        self.repository = repository
    }
    
    func loadCharacter() {
        Task {
            do {
                let character = try await repository.fetchCharacter(id: characterId)
                state = .loaded(character)
            } catch {
                state = .error("Failed to load character: \(error.localizedDescription)")
            }
        }
    }
}
