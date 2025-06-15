@testable import BestMovies
import Foundation
import Nimble
import Quick

class SpyGetMovieReviewsUseCase: GetReviewsUseCaseType {
    var reviewsToReturn: [Review] = []
    var errorToThrow: Error?
    var executeCallCount = 0
    var executeWasCalled: Bool {
        executeCallCount > 0
    }

    var movieIdPassed: Int?

    func execute(movieId: Int) async throws -> [Review] {
        executeCallCount += 1
        movieIdPassed = movieId

        if let error = errorToThrow {
            throw error
        }

        return reviewsToReturn
    }
}

class ReviewsViewModelSpec: AsyncSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("ReviewsViewModel") {
            var sut: ReviewsViewModel!
            var spyUseCase: SpyGetMovieReviewsUseCase!
            var sampleReviews: [Review]!

            beforeEach {
                spyUseCase = SpyGetMovieReviewsUseCase()
                sampleReviews = [
                    Review(
                        id: "1",
                        author: "John Doe",
                        content: "Great movie!",
                        createdAt: Date(),
                        authorDetails: Review.AuthorDetails(
                            name: "John Doe",
                            rating: 8.5,
                            avatarURL: URL(string: "https://image.tmdb.org/t/p/w200/avatar1.jpg")
                        )
                    ),
                    Review(
                        id: "2",
                        author: "Jane Smith",
                        content: "Amazing!",
                        createdAt: Date(),
                        authorDetails: nil
                    )
                ]
                sut = await ReviewsViewModel(movieId: 123, useCase: spyUseCase)
            }

            context("initial state") {
                it("starts in idle state") { @MainActor in
                    expect(sut.state) == .idle
                }
            }

            context("when loading reviews") {
                context("with successful response") {
                    beforeEach {
                        spyUseCase.reviewsToReturn = sampleReviews
                    }

                    it("changes state from idle, to loading, to loaded with reviews") { @MainActor in
                        expect(sut.state) == .idle

                        sut.loadReviews()
                        expect(sut.state) == .loading

                        await expect(sut.state).toEventually(equal(.loaded(sampleReviews)))
                    }

                    it("calls the use case with the correct movie id") { @MainActor in
                        sut.loadReviews()

                        await expect(spyUseCase.executeWasCalled).toEventually(beTrue())
                        await expect(spyUseCase.movieIdPassed).toEventually(equal(123))
                        await expect(spyUseCase.executeCallCount).toEventually(equal(1))
                    }
                }

                context("with empty response") {
                    beforeEach {
                        spyUseCase.reviewsToReturn = []
                    }

                    it("changes state to loaded with empty array") { @MainActor in
                        sut.loadReviews()

                        await expect(sut.state).toEventually(equal(.loaded([])))
                    }
                }

                context("with error response") {
                    beforeEach {
                        spyUseCase.errorToThrow = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
                    }

                    it("changes state from idle, to loading, to error") { @MainActor in
                        expect(sut.state) == .idle

                        sut.loadReviews()
                        expect(sut.state) == .loading

                        await expect(sut.state).toEventually(equal(.error("Failed to load reviews: Test error")))
                    }
                }
            }
        }
    }
}
