import Foundation
import Quick
import Nimble
import Combine
@testable import Mortyverse

class MockGetMoviesUseCase: GetMoviesUseCaseProtocol {
    var moviesToReturn: [Movie] = []
    var hasMoreToReturn: Bool = false
    var errorToThrow: Error?
    var executeCallCount = 0
    var executeWasCalled: Bool {
        executeCallCount > 0
    }
    var lastPageRequested: Int?
    var lastQueryRequested: String?
    
    func execute(page: Int = 1, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        executeCallCount += 1
        lastPageRequested = page
        lastQueryRequested = query
        
        if let error = errorToThrow {
            throw error
        }
        
        return (movies: moviesToReturn, hasMorePages: hasMoreToReturn)
    }
}

@MainActor
class MovieListViewModelSpec: AsyncSpec {
    override class func spec() {
        describe("MovieListViewModel") {
            var sut: MovieListViewModel!
            var mockUseCase: MockGetMoviesUseCase!
            
            beforeEach {
                mockUseCase = MockGetMoviesUseCase()
                sut = await MovieListViewModel(getMoviesUseCase: mockUseCase)
            }
            
            context("initial state") {
                it("starts in idle state") { @MainActor in
                    expect(sut.state) == .idle
                    expect(sut.searchText).to(beEmpty())
                }
                it("does not have any text to search") { @MainActor in
                    expect(sut.searchText).to(beEmpty())
                }
            }
            
            context("when loading movies") {
                let testMovies = [
                    Movie(id: 1, title: "Test 1", overview: "Overview 1", posterPath: "/1.jpg", releaseDate: Date(), voteAverage: 7.5),
                    Movie(id: 2, title: "Test 2", overview: "Overview 2", posterPath: "/2.jpg", releaseDate: Date(), voteAverage: 8.0)
                ]
                
                context("with successful response") {
                    beforeEach {
                        mockUseCase.moviesToReturn = testMovies
                        mockUseCase.hasMoreToReturn = true
                    }
                    
                    it("changes state from idle, to loading, to loaded, with the right movies") { @MainActor in
                        expect(sut.state) == .idle
                        
                        sut.startLoading()
                        expect(sut.state) == .loading
                        
                        await expect(sut.state).toEventually(equal(.loaded(testMovies, currentPage: 1, hasMore: true, isLoadingMore: false)))
                    }
                    
                    it("calls the use case with correct parameters") { @MainActor in
                        sut.startLoading()
                        
                        await expect(mockUseCase.executeCallCount).toEventually(equal(1))
                        await expect(mockUseCase.lastPageRequested).toEventually(equal(1))
                        expect(mockUseCase.lastQueryRequested).to(beEmpty())
                    }
                }
                
                context("with error response") {
                    beforeEach {
                        mockUseCase.errorToThrow = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
                    }
                    
                    it("changes state from idle to loading to error") { @MainActor in
                        expect(sut.state) == .idle
                        
                        sut.startLoading()
                        expect(sut.state) == .loading
                        
                        await expect(sut.state).toEventually(equal(.error("Test error")))
                    }
                }
                
                context("when loading multiple times") {
                    beforeEach {
                        mockUseCase.moviesToReturn = testMovies
                        mockUseCase.hasMoreToReturn = true
                    }
                    it("the use case is called only one time") { @MainActor in
                        sut.startLoading()
                        sut.startLoading()
                        
                        await expect(sut.state).toEventually(equal(.loaded(testMovies, currentPage: 1, hasMore: true, isLoadingMore: false)))
                        
                        expect(mockUseCase.executeWasCalled).to(beTrue())
                        expect(mockUseCase.executeCallCount).to(equal(1))
                    }
                }
                
                context("when loading next page") {
                    beforeEach {
                        mockUseCase.moviesToReturn = testMovies
                        mockUseCase.hasMoreToReturn = true
                    }
                    
                    it("appends new movies to existing ones") { @MainActor in
                        // Load first page
                        sut.startLoading()
                        await expect(sut.state).toEventually(equal(.loaded(testMovies, currentPage: 1, hasMore: true, isLoadingMore: false)))
                        
                        // Configure second page
                        let page2Movies = [
                            Movie(id: 3, title: "Test 3", overview: "Overview 3", posterPath: "/3.jpg", releaseDate: Date(), voteAverage: 8.5)
                        ]
                        mockUseCase.moviesToReturn = page2Movies
                        mockUseCase.hasMoreToReturn = false
                        
                        // Load second page
                        sut.loadNextPage()
                        
                        await expect(sut.state).toEventually(equal(.loaded(testMovies + page2Movies, currentPage: 2, hasMore: false, isLoadingMore: false)))
                        await expect(mockUseCase.lastPageRequested).toEventually(equal(2))
                    }
                }
                
                context("when searching") {
                    it("calls the use case with the right query") { @MainActor in
                        sut.searchText = "test query"
                        
                        await expect(mockUseCase.executeCallCount).toEventually(equal(1))
                        await expect(mockUseCase.lastQueryRequested).toEventually(equal("test query"))
                        await expect(mockUseCase.lastPageRequested).toEventually(equal(1))
                    }
                    
                    it("debounces updates and only the last query is performed") { @MainActor in
                        sut.searchText = "test query1"
                        sut.searchText = "test query2"
                        sut.searchText = "last query"
                        
                        await expect(mockUseCase.executeCallCount).toEventually(equal(1))
                        await expect(mockUseCase.lastQueryRequested).toEventually(equal("last query"))
                        await expect(mockUseCase.lastPageRequested).toEventually(equal(1))
                    }
                    
                    context("and search text changes") {
                        it("changes state to loading, then loaded") { @MainActor in
                            // Load first page
                            mockUseCase.moviesToReturn = testMovies
                            mockUseCase.hasMoreToReturn = true
                            sut.startLoading()
                            
                            await expect(sut.state).toEventually(equal(.loaded(testMovies, currentPage: 1, hasMore: true, isLoadingMore: false)))
                            
                            // Change search text
                            sut.searchText = "new search"
                            
                            await expect(sut.state).toEventually(equal(.loading))
                            await expect(sut.state).toEventually(equal(.loaded(testMovies, currentPage: 1, hasMore: true, isLoadingMore: false)))
                        }
                    }
                }
            }
        }
    }
}
