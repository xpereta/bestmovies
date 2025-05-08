import Combine
import SwiftUI

@MainActor
protocol CharactersListViewModelProtocol: ObservableObject {
    func loadCharacters()
}

enum CharactersListViewState {
    case initial
    case loading
    case loaded([Character])
    case error(message: String)
}

enum CharactersListAction {
    case onAppear
    case retry
    case loadSuccess([Character])
    case loadError(String)
}

@MainActor
final class CharactersListViewModel: CharactersListViewModelProtocol {
    @Published private(set) var state: CharactersListViewState = .initial
    
    private let useCase: GetCharactersUseCase
    
    init(useCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.useCase = useCase
    }
    
    func send(_ action: CharactersListAction) {
        if let effect = reducer(state: &state, action: action) {
            effect()
        }
    }
    
    func loadCharacters() {
        Task {
            do {
                let characters = try await useCase.execute()
                self.send(.loadSuccess(characters))
            } catch let error {
                let errorMessage = "Error fetching characters."
                print("Error running use case: \(errorMessage)")
                self.send(.loadError(errorMessage))
            }
        }
    }
    
    private func reducer(state: inout CharactersListViewState, action: CharactersListAction) -> (()->Void)? {
        switch action {
        case .onAppear:
            state = .loading
            return { self.loadCharacters() }
            //return { [weak self] in self?.loadCharacters() }
            
        case .retry:
            state = .loading
            return { self.loadCharacters() }

        case .loadSuccess(let characters):
            state = .loaded(characters)
            return nil
        
        case .loadError(let message):
            state = .error(message: message)
            return nil
        }
    }
}
