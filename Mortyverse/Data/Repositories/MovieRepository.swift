import Foundation

protocol MovieRepositoryProtocol {
    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool)
}

final class MovieRepository: MovieRepositoryProtocol {
    private let apiClient: TMDBAPIClientProtocol
    
    init(apiClient: TMDBAPIClientProtocol = TMDBAPIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        let response: MovieResponse
        
        if let query = query, !query.isEmpty {
            response = try await apiClient.searchMovies(query: query, page: page)
        } else {
            response = try await apiClient.fetchMovies(page: page)
        }
        
        let movies = MovieDTOMapper.mapList(response.results)
        let hasMorePages = response.page < response.totalPages
        
        return (movies: movies, hasMorePages: hasMorePages)
    }
}
