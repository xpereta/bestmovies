import SwiftUI

enum AppPage: Hashable {
    case moviesList
    case movieDetails(Int)
}

class Coordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    
    func push(page: AppPage) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    @ViewBuilder
    func build(page: AppPage) -> some View {
        switch page {
        case .moviesList:
            MovieListView()
        case .movieDetails(let id):
            MovieDetailView(movieId: id)
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


