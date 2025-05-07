import Combine
import SwiftUI

@MainActor
protocol CharactersListViewModelProtocol: ObservableObject {
    func loadCharacters()
}

@MainActor
final class CharactersListViewModel: CharactersListViewModelProtocol {
    @Published private(set) var characters: [Character] = []
    @Published private(set) var isLoading = false
    
    private let useCase: GetCharactersUseCase
    
    init(useCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.useCase = useCase
    }
    
    func loadCharacters() {
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            do {
                characters = try await useCase.execute()
            } catch let error {
                print("Error running use case: \(error)")
            }
            isLoading = false
        }
    }
}
