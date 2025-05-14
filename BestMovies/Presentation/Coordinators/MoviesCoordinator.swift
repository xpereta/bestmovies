import SwiftUI

enum AppPage: Hashable {
    case moviesList
    case movieDetails(Int)
}

class Coordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    private let apiConfiguration = TMDBConfiguration(baseURL: "https://api.themoviedb.org/3", apiKey: "97d24ffef95aebe28225de0c524590d9")
    
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
            let repository = MovieRepository(apiConfiguration: apiConfiguration)
            let useCase = GetMoviesUseCase(repository: repository)
            let viewModel = MovieListViewModel(getMoviesUseCase: useCase)
            
            MovieListView(viewModel: viewModel)
        case .movieDetails(let id):
            let repository = MovieRepository(apiConfiguration: apiConfiguration)
            let useCase = GetMovieDetailsUseCase(repository: repository)
            let viewModel = MovieDetailViewModel(movieId: id, useCase: useCase)
            
            MovieDetailView(viewModel: viewModel)
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


