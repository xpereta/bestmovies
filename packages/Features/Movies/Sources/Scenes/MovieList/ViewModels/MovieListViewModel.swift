import AsyncAlgorithms
import BestMoviesDomain
import Combine
import Foundation

enum MoviesListViewState: Equatable {
    case idle
    case loading
    case loaded([Movie], currentPage: Int, hasMore: Bool, isLoadingMore: Bool)
    case error(String)
}

@MainActor
protocol MovieListViewModelType: ObservableObject {
    var state: MoviesListViewState { get }
    var searchText: String { get set }

    func startLoading() async
    func loadNextPage() async
    func resetLoading() async
    
    func movieTapped(id: Int)
}

@MainActor
final class StubMovieListViewModel: MovieListViewModelType {
    @Published var state: MoviesListViewState
    @Published var searchText: String = ""
    
    init(state: MoviesListViewState, searchText: String = "") {
        self.state = state
        self.searchText = searchText
    }

    func startLoading() async {}
    func loadNextPage() async {}
    func resetLoading() async {}
    
    func movieTapped(id: Int) {}
}

@MainActor
final class MovieListViewModel: MovieListViewModelType {
    @Published private(set) var state: MoviesListViewState = .idle
    @Published var searchText: String = "" {
        didSet {
            continuation.yield(searchText)
        }
    }

    private var previousSearchText: String = ""

    let (textStream, continuation) = AsyncStream.makeStream(of: String.self)

    private let useCase: GetMoviesUseCaseType
    private var loadTask: Task<Void, Never>?

    private var searchTask: Task<Void, Never>?

    private let onMovieSelection: (Int) -> Void
    
    init(useCase: GetMoviesUseCaseType, onMovieSelection: @escaping (Int) -> Void) {
        self.useCase = useCase
        self.onMovieSelection = onMovieSelection
        setupSearchTask()
    }

    deinit {
        searchTask?.cancel()
        loadTask?.cancel()
    }

    private func setupSearchTask() {
        searchTask = Task {
            for await searchText in self.textStream.debounce(for: .milliseconds(350)) {
                guard searchText != self.previousSearchText else {
                    continue
                }

                previousSearchText = searchText

                state = .loading

                await self.resetAndLoad()
            }
        }
    }

    func startLoading() async {
        print("🧠 MovieListViewModel: startLoading")
        guard case .idle = state else { return }

        state = .loading
        print("****** State set to .loading ******")

        await resetAndLoad()
    }

    private func resetAndLoad() async {
        print("🧠 MovieListViewModel: resetAndLoad")

        loadTask?.cancel()

        loadTask = Task {
            do {
                let result = try await useCase.execute(page: 1, query: searchText)
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

    func resetLoading() async {
        await resetAndLoad()
    }

    func loadNextPage() async {
        guard case .loaded(let movies, let currentPage, true, false) = state else { return }

        let nextPage = currentPage + 1

        Task {
            do {
                let result = try await useCase.execute(page: nextPage, query: searchText)
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
    
    // MARK: Navigation
    func movieTapped(id: Int) {
        onMovieSelection(id)
    }
}
