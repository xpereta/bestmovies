@testable import Domain
import Foundation
import Testing

final class GetMoviesUseCaseTests {

    @Test("GetMoviesUseCase executes with default page")
    func testGetMoviesUseCaseExecutesWithDefaultPage() async throws {
        // Given
        let repositorySpy = MovieRepositorySpyFetchMovies()
        let useCase = GetMoviesUseCase(repository: repositorySpy)
        let expectedMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", releaseDate: nil, voteAverage: 8.0, posterURL: nil),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", releaseDate: nil, voteAverage: 7.5, posterURL: nil)
        ]
        repositorySpy.moviesToReturn = expectedMovies
        repositorySpy.hasMorePagesToReturn = true

        // When
        let result = try await useCase.execute(page: 1, query: nil)

        // Then
        #expect(repositorySpy.fetchMoviesCallCount == 1)
        #expect(repositorySpy.lastPage == 1)
        #expect(repositorySpy.lastQuery == nil)
        #expect(result.movies == expectedMovies)
        #expect(result.hasMorePages == true)
    }

    @Test("GetMoviesUseCase executes with custom page and query")
    func testGetMoviesUseCaseExecutesWithCustomPageAndQuery() async throws {
        // Given
        let repositorySpy = MovieRepositorySpyFetchMovies()
        let useCase = GetMoviesUseCase(repository: repositorySpy)
        let expectedMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", releaseDate: nil, voteAverage: 8.0, posterURL: nil)
        ]
        repositorySpy.moviesToReturn = expectedMovies
        repositorySpy.hasMorePagesToReturn = false

        // When
        let result = try await useCase.execute(page: 2, query: "Movie")

        // Then
        #expect(repositorySpy.fetchMoviesCallCount == 1)
        #expect(repositorySpy.lastPage == 2)
        #expect(repositorySpy.lastQuery == "Movie")
        #expect(result.movies == expectedMovies)
        #expect(result.hasMorePages == false)
    }

    @Test("GetMoviesUseCase propagates repository error")
    func testGetMoviesUseCasePropagatesRepositoryError() async {
        // Given
        let repositorySpy = MovieRepositorySpyFetchMovies()
        let useCase = GetMoviesUseCase(repository: repositorySpy)
        let expectedError = NSError(domain: "test", code: 1)
        repositorySpy.errorToThrow = expectedError

        // When/Then
        do {
            _ = try await useCase.execute(page: 1, query: nil)
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error as NSError == expectedError)
        }
    }
}
