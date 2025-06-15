import Combine
import Foundation
import Domain

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
                async let movieResult = try await getMovieDetailsUseCase.execute(movieId: movieId)
                async let reviewsResult = try await getReviewsUseCase.execute(movieId: self.movieId)

                let (movie, reviews) = try await (movieResult, reviewsResult)

                state = .loaded(movie, reviews)
            } catch {
                state = .error("Failed to load movie details: \(error.localizedDescription)")
            }
        }
    }
}
