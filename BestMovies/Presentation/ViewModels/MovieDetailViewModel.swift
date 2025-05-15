import Foundation
import Combine

@MainActor
protocol MovieDetailViewModelType: ObservableObject {
    var state: MovieDetailViewModel.State { get }
    func loadMovie()
}

@MainActor
final class StubMovieDetailViewModel: MovieDetailViewModelType {
    @Published var state: MovieDetailViewModel.State
    
    init(state: MovieDetailViewModel.State) {
        self.state = state
    }
    
    func loadMovie() {}
}

@MainActor
final class MovieDetailViewModel: MovieDetailViewModelType {
    enum State: Equatable {
        case idle
        case loading
        case loaded(MovieDetails)
        case error(String)
    }
    
    @Published private(set) var state: State = .idle
    
    private let getMovieDetailsUseCase: GetMovieDetailsUseCaseType
    private let movieId: Int
    
    init(movieId: Int, useCase: GetMovieDetailsUseCaseType) {
        self.movieId = movieId
        self.getMovieDetailsUseCase = useCase
    }
    
    func loadMovie() {
        print("🧠 MovieDetailViewModel: loadMovie")
        guard case .idle = state else { return }

        state = .loading
        
        Task {
            do {
                let movie = try await getMovieDetailsUseCase.execute(movieId: movieId)
                state = .loaded(movie)
            } catch {
                state = .error("Failed to load movie details: \(error.localizedDescription)")
            }
        }
    }
}
