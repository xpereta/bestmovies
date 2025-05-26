import AsyncAlgorithms
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

    func startLoading()
    func loadNextPage()
}

@MainActor
final class StubMovieListViewModel: MovieListViewModelType {
    @Published var state: MoviesListViewState
    @Published var searchText: String = ""

    init(state: MoviesListViewState, searchText: String = "") {
        self.state = state
        self.searchText = searchText
    }

    func startLoading() {}
    func loadNextPage() {}
}

@MainActor
final class MovieListViewModel: MovieListViewModelType {
    @Published private(set) var state: MoviesListViewState = .idle
    @Published var searchText: String = "" {
        didSet {
            continuation.yield(searchText)
        }
    }

    let (textStream, continuation) = AsyncStream.makeStream(of: String.self)

    private let useCase: GetMoviesUseCaseType
    private var loadTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    private var searchTask: Task<Void, Never>!

    init(useCase: GetMoviesUseCaseType) {
        self.useCase = useCase
        setupSearchTask()
    }

    deinit {
        cancellables.removeAll()
    }

    private func setupSearchTask() {
        searchTask = Task {
            for await searchText in self.textStream {
                guard !searchText.isEmpty else {
                    continue
                }

                self.resetAndLoad()
            }
        }
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

    func loadNextPage() {
        guard case .loaded(let movies, let currentPage, true, false) = state else { return }

        let nextPage = currentPage + 1
        state = .loaded(movies, currentPage: currentPage, hasMore: true, isLoadingMore: true)

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
}
