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
    case loadStarted
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
        reducer(state: &state, action: action)
        
        switch action {
        case .onAppear:
            send(.loadStarted)
            loadCharacters()
        default:
            break
        }
    }
    
    func loadCharacters() {
        send(.loadStarted)
        
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
    
    func retry() {
        loadCharacters()
    }
    
    private func reducer(state: inout CharactersListViewState, action: CharactersListAction) {
        switch action {
        case .onAppear:
            loadCharacters()
        case .loadStarted:
            break
        case .loadSuccess(let characters):
            state = .loaded(characters)
        case .loadError(let errorMessage):
            state = .error(message: errorMessage)
        }
    }
}
