import FactoryKit
import SwiftUI

enum AppPage: Hashable {
    case moviesList
    case movieDetails(Int)
}

@MainActor
class Coordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()

    lazy var getMoviesUseCase = Container.shared.getMoviesUseCase()
    lazy var moviesListViewModel = MovieListViewModel(useCase: getMoviesUseCase)

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
            let movieDetailsUseCase = Container.shared.getMovieDetailsUseCase()
            let reviewsUseCase = Container.shared.getReviewsUseCase()
            let movieDetailsViewModel = MovieDetailViewModel(movieId: id, getMovieDetailsUseCase: movieDetailsUseCase, getReviewsUseCase: reviewsUseCase)

            MovieDetailView(viewModel: movieDetailsViewModel)
        }
    }
}

struct CoordinatorView: View {
    @StateObject private var coordinator = Coordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .moviesList)
                .navigationDestination(for: AppPage.self) { page in
                    coordinator.build(page: page)
                }
        }
        .environmentObject(coordinator)
    }
}
