import Foundation
import Combine

@MainActor
protocol SimpleCharactersListViewModelProtocol: ObservableObject {
    func starLoading()
    func loadNextPage()
}

@MainActor
final class SimpleCharactersListViewModel: SimpleCharactersListViewModelProtocol {
    @Published private(set) var isLoading = false
    @Published private(set) var currentPage = 1
    @Published private(set) var hasMorePages = false
    @Published private(set) var characters: [Character] = []
    @Published private(set) var errorMessage: String? = nil
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    private let getCharactersUseCase: GetCharactersUseCase
    private var searchTask: Task<Void, Never>?
    
    init(getCharactersUseCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.getCharactersUseCase = getCharactersUseCase
        setupSearchSubscriber()
    }
    
    deinit {
        cancellables.removeAll()
        searchTask?.cancel()
    }
    
    private func setupSearchSubscriber() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                print("Received new value: \(searchText)")
                self?.resetAndSearch()
            }
            .store(in: &cancellables)
    }
    
    private func resetAndSearch() {
        searchTask?.cancel()
        characters = []
        currentPage = 1
        hasMorePages = false
        
        searchTask = Task {
            starLoading()
        }
    }
    
    func starLoading() {
        print("ViewModel: Start loading called")
        guard !isLoading else { return }
        guard characters.isEmpty else { return }
        
        isLoading = true
        loadCharacters(page: currentPage)
    }
    
    func loadNextPage() {
        print("ViewModel: load next page called")
        guard !isLoading else { return }
        
        isLoading = true
        loadCharacters(page: currentPage + 1)
    }
    
    func onDissapear() {
        searchTask?.cancel()
    }
    
    private func loadCharacters(page: Int) {
        Task {
            do {
                let searchQuery = searchText.isEmpty ? nil : searchText
                let paginatedResult = try await getCharactersUseCase.execute(page: page, name: searchQuery)
                characters.append(contentsOf: paginatedResult.characters)
                errorMessage = nil
                currentPage = page
                hasMorePages = paginatedResult.hasMorePages
            } catch let error {
                errorMessage = "Error getting characters: \(error.localizedDescription)."
            }
            isLoading = false
        }
    }
}
