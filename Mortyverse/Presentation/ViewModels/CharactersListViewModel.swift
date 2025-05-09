import Combine

@MainActor
protocol CharactersListViewModelProtocol: ObservableObject {
    func loadCharacters(page: Int)
}

enum CharactersListViewState {
    case initial
    case loading
    case loadingNextPage(existingCharacters: [Character])
    case loaded(characters: [Character], currentPage: Int, hasNextPage: Bool)
    case error(message: String)
}

enum CharactersListAction {
    case onAppear
    case loadNextPage
    case retry
    case loadSuccess(PaginatedCharacters)
    case loadError(String)
}

@MainActor
final class CharactersListViewModel: CharactersListViewModelProtocol {
    @Published private(set) var state: CharactersListViewState = .initial
    private var isLoading = false
    private var currentPage = 1
    
    private let useCase: GetCharactersUseCase
    
    init(useCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.useCase = useCase
    }
    
    func send(_ action: CharactersListAction) {
        if let effect = reducer(state: &state, action: action) {
            effect()
        }
    }
    
    func loadCharacters(page: Int = 1) {
        Task {
            do {
                let paginatedResult = try await useCase.execute(page: page)
                self.send(.loadSuccess(paginatedResult))
            } catch let error {
                let errorMessage = "Error fetching characters: \(error.localizedDescription)."
                self.send(.loadError(errorMessage))
            }
        }
    }
    
    private func reducer(state: inout CharactersListViewState, action: CharactersListAction) -> (()->Void)? {
        switch action {
        case .onAppear:
            guard isLoading == false else { return nil }

            state = .loading
            isLoading = true
            currentPage = 1
            
            return { [weak self] in self?.loadCharacters(page: 1) }
            
        case .loadNextPage:
            guard isLoading == false else { return nil }
            guard case let .loaded(characters, page, hasNext) = state,
                  hasNext else { return nil }
            
            state = .loadingNextPage(existingCharacters: characters)
            isLoading = true
            
            return { [weak self] in self?.loadCharacters(page: page + 1) }
            
        case .retry:
            guard isLoading == false else { return nil }
            
            state = .loading
            isLoading = true
            currentPage = 1

            return { [weak self] in self?.loadCharacters(page: 1) }

        case .loadSuccess(let result):
            let updatedCharacters: [Character] = {
                if case let .loadingNextPage(existingCharacters) = state {
                    return existingCharacters + result.characters
                }
                return result.characters
            }()
            
            state = .loaded(
                characters: updatedCharacters,
                currentPage: result.currentPage,
                hasNextPage: result.hasMorePages
            )
            isLoading = false
            
            return nil
        
        case .loadError(let message):
            state = .error(message: message)
            isLoading = false
            
            return nil
        }
    }
}
