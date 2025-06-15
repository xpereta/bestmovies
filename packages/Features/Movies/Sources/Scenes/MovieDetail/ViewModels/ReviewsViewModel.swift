import BestMoviesDomain
import Combine
import Foundation

@MainActor
protocol ReviewsViewModelType: ObservableObject {
    var state: ReviewsViewModel.State { get }

    func loadReviews()
}

@MainActor
final class StubReviewsViewModel: ReviewsViewModelType {
    @Published var state: ReviewsViewModel.State

    init(state: ReviewsViewModel.State) {
        self.state = state
    }

    func loadReviews() {}
}

@MainActor
final class ReviewsViewModel: ReviewsViewModelType {
    enum State: Equatable {
        case idle
        case loading
        case loaded([Review])
        case error(String)
    }

    @Published private(set) var state: State = .idle

    private let getReviewsUseCase: GetReviewsUseCaseType
    private let movieId: Int

    init(movieId: Int, useCase: GetReviewsUseCaseType) {
        self.movieId = movieId
        getReviewsUseCase = useCase
    }

    func loadReviews() {
        guard case .idle = state else { return }

        state = .loading

        Task {
            do {
                let reviews = try await getReviewsUseCase.execute(movieId: movieId)
                state = .loaded(reviews)
            } catch {
                state = .error("Failed to load reviews: \(error.localizedDescription)")
            }
        }
    }
}
