@testable import Domain
import Foundation
import Testing

final class GetMovieDetailsUseCaseTests {
    @Test("GetMovieDetailsUseCase executes successfully")
    func testGetMovieDetailsUseCaseExecutesSuccessfully() async throws {
        // Given
        let repositorySpy = MoveRepositorySpyFetchMovieDetails()
        let useCase = GetMovieDetailsUseCase(repository: repositorySpy)
        let expectedMovieDetails = MovieDetails(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            releaseDate: nil,
            voteAverage: 8.5,
            voteCount: 1000,
            runtime: 120,
            genres: [],
            status: "Released",
            tagline: nil,
            budget: 1000000,
            revenue: 5000000,
            originalLanguage: "en",
            posterURL: nil,
            backdropURL: nil
        )
        repositorySpy.movieDetailsToReturn = expectedMovieDetails

        // When
        let result = try await useCase.execute(movieId: 1)

        // Then
        #expect(repositorySpy.fetchMovieDetailsCallCount == 1)
        #expect(repositorySpy.lastMovieId == 1)
        #expect(result == expectedMovieDetails)
    }

    @Test("GetMovieDetailsUseCase propagates movie not found error")
    func testGetMovieDetailsUseCasePropagatesMovieNotFoundError() async {
        // Given
        let repositorySpy = MoveRepositorySpyFetchMovieDetails()
        let useCase = GetMovieDetailsUseCase(repository: repositorySpy)
        repositorySpy.movieDetailsToReturn = nil

        // When/Then
        do {
            _ = try await useCase.execute(movieId: 999)
            Issue.record("Expected error to be thrown")
        } catch MovieRepositoryError.movieNotFound(let id) {
            #expect(id == 999)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("GetMovieDetailsUseCase propagates repository error")
    func testGetMovieDetailsUseCasePropagatesRepositoryError() async {
        // Given
        let repositorySpy = MoveRepositorySpyFetchMovieDetails()
        let useCase = GetMovieDetailsUseCase(repository: repositorySpy)
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
