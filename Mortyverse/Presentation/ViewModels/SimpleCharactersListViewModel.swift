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
    
    private let useCase: GetCharactersUseCase

    init(useCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.useCase = useCase
    }
    
    func starLoading() {
        print("ViewModel: Start loading called")
        
        guard !isLoading else { return }
        
        isLoading = true
        loadCharacters(page: currentPage)
    }
    
    func loadNextPage() {
        print("ViewModel: load next page called")

        guard !isLoading else { return }
        
        isLoading = true
        loadCharacters(page: currentPage + 1)
    }
    
    private func loadCharacters(page: Int) {
        Task {
            do {
                let paginatedResult = try await useCase.execute(page: page)
                characters.append(contentsOf: paginatedResult.characters)
                errorMessage = nil
                currentPage = page
                hasMorePages = paginatedResult.hasMorePages
            } catch let error {
                errorMessage = "Error fetching characters: \(error.localizedDescription)."
            }
            isLoading = false
        }
    }
}
