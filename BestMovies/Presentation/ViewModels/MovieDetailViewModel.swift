import Combine
import Foundation

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
        case loaded(MovieDetails, [Review])
        case error(String)
    }

    @Published private(set) var state: State = .idle

    private let getMovieDetailsUseCase: GetMovieDetailsUseCaseType
    private let getReviewsUseCase: GetReviewsUseCaseType
    private let movieId: Int

    init(movieId: Int, getMovieDetailsUseCase: GetMovieDetailsUseCaseType, getReviewsUseCase: GetReviewsUseCaseType ) {
        self.movieId = movieId
        self.getMovieDetailsUseCase = getMovieDetailsUseCase
        self.getReviewsUseCase = getReviewsUseCase
    }

    func loadMovie() {
        print("🧠 MovieDetailViewModel: loadMovie")
        guard case .idle = state else { return }

        state = .loading

        Task {
            do {
                let movie = try await getMovieDetailsUseCase.execute(movieId: movieId)
                state = .loaded(movie, [])

                loadReviews()
            } catch {
                state = .error("Failed to load movie details: \(error.localizedDescription)")
            }
        }
    }

    private func loadReviews() {
        Task {
            guard case .loaded(let movieDetails, _) = state else { return }

            let reviews = try await getReviewsUseCase.execute(movieId: self.movieId)

            state = .loaded(movieDetails, reviews)
        }
    }
}
