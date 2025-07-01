import BestMoviesDomain
import SwiftUI

enum AppPage: Hashable {
    case moviesList
    case movieDetails(Int)
}

// Protocol defining the dependencies needed by the Movies feature
public protocol MoviesDependencies {
    var getMoviesUseCase: GetMoviesUseCaseType { get }
    var getMovieDetailsUseCase: GetMovieDetailsUseCaseType { get }
    var getReviewsUseCase: GetReviewsUseCaseType { get }
}

@MainActor
class Coordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()

    private let dependencies: MoviesDependencies
    lazy var moviesListViewModel: MovieListViewModel = MovieListViewModel(
        useCase: dependencies.getMoviesUseCase,
        onMovieSelection: { [weak self] movieId in
            self?.push(page: .movieDetails(movieId))
        }
    )

    init(dependencies: MoviesDependencies) {
        self.dependencies = dependencies
    }

    func push(page: AppPage) {
        path.append(page)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    @MainActor @ViewBuilder
    func build(page: AppPage) -> some View {
        switch page {
        case .moviesList:
            MovieListView(viewModel: self.moviesListViewModel)
        case .movieDetails(let id):
            let movieDetailsViewModel = MovieDetailViewModel(
                movieId: id,
                getMovieDetailsUseCase: dependencies.getMovieDetailsUseCase,
                getReviewsUseCase: dependencies.getReviewsUseCase
            )
            MovieDetailView(viewModel: movieDetailsViewModel)
        }
    }
}

public struct CoordinatorView: View {
    @StateObject private var coordinator: Coordinator

    public init(dependencies: MoviesDependencies) {
        _coordinator = StateObject(wrappedValue: Coordinator(dependencies: dependencies))
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .moviesList)
                .navigationDestination(for: AppPage.self) { page in
                    coordinator.build(page: page)
                }
        }
    }
}
