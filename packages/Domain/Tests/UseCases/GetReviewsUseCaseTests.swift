@testable import Domain
import Foundation
import Testing

final class GetReviewsUseCaseTests {

    @Test("GetReviewsUseCase executes successfully with reviews")
    func testGetReviewsUseCaseExecutesSuccessfullyWithReviews() async throws {
        // Given
        let repositorySpy = MockMovieRepositorySpyFetchReviews()
        let useCase = GetReviewsUseCase(repository: repositorySpy)
        let expectedReviews = [
            Review(
                id: "review1",
                author: "John Doe",
                content: "Great movie!",
                createdAt: nil,
                authorDetails: Review.AuthorDetails(
                    name: "John Doe",
                    rating: 8.5,
                    avatarURL: nil
                )
            ),
            Review(
                id: "review2",
                author: "Jane Smith",
                content: "Amazing film!",
                createdAt: nil,
                authorDetails: Review.AuthorDetails(
                    name: "Jane Smith",
                    rating: 9.0,
                    avatarURL: nil
                )
            )
        ]
        repositorySpy.reviewsToReturn = expectedReviews

        // When
        let result = try await useCase.execute(movieId: 1)

        // Then
        #expect(repositorySpy.fetchReviewsCallCount == 1)
        #expect(repositorySpy.lastMovieId == 1)
        #expect(result == expectedReviews)
    }

    @Test("GetReviewsUseCase executes successfully with empty reviews")
    func testGetReviewsUseCaseExecutesSuccessfullyWithEmptyReviews() async throws {
        // Given
        let repositorySpy = MockMovieRepositorySpyFetchReviews()
        let useCase = GetReviewsUseCase(repository: repositorySpy)
        repositorySpy.reviewsToReturn = []

        // When
        let result = try await useCase.execute(movieId: 1)

        // Then
        #expect(repositorySpy.fetchReviewsCallCount == 1)
        #expect(repositorySpy.lastMovieId == 1)
        #expect(result.isEmpty)
    }

    @Test("GetReviewsUseCase propagates repository error")
    func testGetReviewsUseCasePropagatesRepositoryError() async {
        // Given
        let repositorySpy = MockMovieRepositorySpyFetchReviews()
        let useCase = GetReviewsUseCase(repository: repositorySpy)
        let expectedError = NSError(domain: "test", code: 1)
        repositorySpy.errorToThrow = expectedError

        // When/Then
        do {
            _ = try await useCase.execute(movieId: 1)
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error as NSError == expectedError)
        }
    }
}
