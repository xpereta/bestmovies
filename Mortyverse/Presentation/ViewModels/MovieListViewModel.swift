import Foundation
import Combine

enum MoviesListViewState {
    case idle
    case loading
    case loaded([Movie], currentPage: Int, hasMore: Bool, isLoadingMore: Bool)
    case error(String)
}

@MainActor
final class MovieListViewModel: ObservableObject {
    @Published private(set) var state: MoviesListViewState = .idle
    @Published var searchText: String = ""
    
    private let getMoviesUseCase: GetMoviesUseCase
    private var loadTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(getMoviesUseCase: GetMoviesUseCase) {
        self.getMoviesUseCase = getMoviesUseCase
        setupSearchSubscription()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private func setupSearchSubscription() {
        print("🧠 MovieListViewModel: setupSearchSubscription")
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.resetAndLoad()
            }
            .store(in: &cancellables)
    }
    
    func startLoading() {
        print("🧠 MovieListViewModel: startLoading")
        guard case .idle = state else { return }
        
        resetAndLoad()
    }
    
    private func resetAndLoad() {
        print("🧠 MovieListViewModel: resetAndLoad")

        loadTask?.cancel()
        
        state = .loading
        
        loadTask = Task {
            do {
                let result = try await getMoviesUseCase.execute(page: 1, query: searchText)
                guard !Task.isCancelled else {
                    state = .idle
                    return
                }
                state = .loaded(
                    result.movies,
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
        guard case let .loaded(movies, currentPage, true, false) = state else { return }
        
        let nextPage = currentPage + 1
        state = .loaded(movies, currentPage: currentPage, hasMore: true, isLoadingMore: true)
        
        Task {
            do {
                let result = try await getMoviesUseCase.execute(page: nextPage, query: searchText)
                state = .loaded(
                    movies + result.movies,
                    currentPage: nextPage,
                    hasMore: result.hasMorePages,
                    isLoadingMore: false
                )
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
