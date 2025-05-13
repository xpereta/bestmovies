import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded(MovieDetails)
        case error(String)
    }
    
    @Published private(set) var state: State = .idle
    
    private let getMovieDetailsUseCase: GetMovieDetailsUseCase
    private let movieId: Int
    
    init(movieId: Int, useCase: GetMovieDetailsUseCase) {
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
