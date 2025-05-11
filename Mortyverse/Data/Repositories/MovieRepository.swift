import Foundation

enum MovieRepositoryError: LocalizedError {
    case movieNotFound(withId: Int)
    
    var errorDescription: String? {
        switch self {
        case .movieNotFound(let withId):
            return "Movie not found with id \(withId)."
        }
    }
}

protocol MovieRepositoryProtocol {
    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool)
    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails
}

final class MovieRepository: MovieRepositoryProtocol {
    private let apiClient: TMDBAPIClientProtocol
    private let apiProvider: ApiProvider

    
    init(apiClient: TMDBAPIClientProtocol = TMDBAPIClient()) {
        self.apiClient = apiClient
        self.apiProvider = URLSessionApiProvider()
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
    
    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails {
        do {
//            let movie = try await apiClient.fetchMovie(id)
            let request = try TMDBApiEndpoint.movie(id: id).makeURLRequest()
            let movie = try await apiProvider.performRequest(request, decodeTo: MovieDetailsDTO.self)
            return MovieDetailsDTOMapper.map(movie)
        } catch ApiProviderError.failed(statusCode: 404) {
            throw MovieRepositoryError.movieNotFound(withId: id)
        }
    }
}
