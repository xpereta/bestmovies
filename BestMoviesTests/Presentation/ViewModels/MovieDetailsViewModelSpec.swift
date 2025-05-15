import Foundation
import Quick
import Nimble
@testable import BestMovies

class MockGetMovieDetailsUseCase: GetMovieDetailsUseCaseType {
    var movieToReturn: MovieDetails?
    var errorToThrow: Error?
    var executeCallCount = 0
    var executeWasCalled: Bool {
        executeCallCount > 0
    }
    var movieIdPassed: Int?
    
    func execute(movieId: Int) async throws -> MovieDetails {
        executeCallCount += 1
        movieIdPassed = movieId
        
        if let error = errorToThrow {
            throw error
        }
        
        if let movie = movieToReturn {
            return movie
        }
        
        throw NSError(domain: "Test", code: -1)
    }
}

class MovieDetailViewModelSpec: AsyncSpec {
    override class func spec() {
        describe("MovieDetailViewModel") {
            var sut: MovieDetailViewModel!
            var mockUseCase: MockGetMovieDetailsUseCase!
            var movie: MovieDetails!
            
            beforeEach {
                mockUseCase = MockGetMovieDetailsUseCase()
                movie = MovieDetails(
                    id: 123,
                    title: "Test Movie",
                    overview: "Test Overview",
                    posterPath: "/test.jpg",
                    backdropPath: "/backdrop.jpg",
                    releaseDate: Date(),
                    voteAverage: 8.5,
                    voteCount: 100,
                    runtime: 120,
                    genres: [],
                    status: "Released",
                    tagline: "Test Tagline",
                    budget: 1000000,
                    revenue: 5000000,
                    originalLanguage: "en"
                )

                sut = await MovieDetailViewModel(movieId: 123, useCase: mockUseCase)
            }
            
            context("initial state") {
                it("starts in idle state") { @MainActor in
                    expect(sut.state).to(equal(.idle))
                }
            }
            
            context("when loading a movie") {
                context("with successful response") {
                    beforeEach {
                        mockUseCase.movieToReturn = movie
                    }
                    
                    it("changes the state from idle, to loading, to loaded, with the correct movie") { @MainActor in
                        expect(sut.state).to(equal(.idle))
                        
                        sut.loadMovie()
                        
                        expect(sut.state).to(equal(.loading))
                        
                        await expect(sut.state).toEventually(equal(.loaded(mockUseCase.movieToReturn!)))
                        
                        await expect(sut.state).toEventually(equal(.loaded(movie)))
                    }
                    
                    it("calls the use case with the correct movie id") { @MainActor in
                        sut.loadMovie()
                        await expect(mockUseCase.executeWasCalled).toEventually(beTrue())
                        await expect(mockUseCase.movieIdPassed).toEventually(equal(123))
                    }
                }
                
                context("with error response") {
                    beforeEach {
                        mockUseCase.errorToThrow = MovieRepositoryError.movieNotFound(withId: 123)
                    }
                    
                    it("changes state from idle, to loading, to error") { @MainActor in
                        expect(sut.state).to(equal(.idle))
                        
                        sut.loadMovie()
                        
                        expect(sut.state).to(equal(.loading))
                        
                        await expect(sut.state).toEventually(equal(.error("Failed to load movie details: Movie not found with id 123.")))
                    }
                }
                
                context("when loading multiple times") {
                    it("use case is called only one time") { @MainActor in
                        sut.loadMovie()
                        sut.loadMovie()
                        
                        await expect(mockUseCase.executeWasCalled).toEventually(beTrue())
                        expect(mockUseCase.executeWasCalled).to(beTrue())
                        expect(mockUseCase.executeCallCount).to(equal(1))
                    }
                }
            }
        }
    }
}
