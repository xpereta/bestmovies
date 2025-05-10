import Foundation
import Combine

enum CharactersListViewState {
    case idle
    case loading
    case loaded([Character], currentPage: Int, hasMore: Bool, isLoadingMore: Bool)
    case error(String)
}

@MainActor
final class CharactersListViewModel: ObservableObject {
    @Published private(set) var state: CharactersListViewState = .idle
    @Published var searchText: String = ""
    
    private let getCharactersUseCase: GetCharactersUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(getCharactersUseCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.getCharactersUseCase = getCharactersUseCase
        setupSearchSubscription()
    }
    
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.resetAndLoad()
            }
            .store(in: &cancellables)
    }
    
    func startLoading() {
        guard case .idle = state else { return }
        
        resetAndLoad()
    }
    
    private func resetAndLoad() {
        state = .loading
        
        Task {
            do {
                let result = try await getCharactersUseCase.execute(page: 1, name: searchText)
                state = .loaded(
                    result.characters,
                    currentPage: 1,
                    hasMore: result.hasMorePages,
                    isLoadingMore: false
                )
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func loadNextPage() {
        guard case let .loaded(characters, currentPage, true, false) = state else { return }
        
        let nextPage = currentPage + 1
        state = .loaded(characters, currentPage: currentPage, hasMore: true, isLoadingMore: true)
        
        Task {
            do {
                let result = try await getCharactersUseCase.execute(page: nextPage, name: searchText)
                state = .loaded(
                    characters + result.characters,
                    currentPage: nextPage,
                    hasMore: result.hasMorePages,
                    isLoadingMore: false
                )
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func onDissapear() {
        cancellables.removeAll()
    }
}
