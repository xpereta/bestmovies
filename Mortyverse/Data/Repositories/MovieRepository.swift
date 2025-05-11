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
    private let apiProvider: ApiProvider

    init(apiProvider: ApiProvider = URLSessionApiProvider()) {
        self.apiProvider = apiProvider
    }
    
    func fetchMovies(page: Int, query: String?) async throws -> (movies: [Movie], hasMorePages: Bool) {
        let response: MovieResponse
        let request: URLRequest
        
        if let query = query, !query.isEmpty {
            request = try TMDBApiEndpoint.searchMovies(query: query, page: page).makeURLRequest()
        } else {
            request = try TMDBApiEndpoint.topRated(page: page).makeURLRequest()
        }
        
        response = try await apiProvider.performRequest(request, decodeTo: MovieResponse.self)
        
        let movies = MovieDTOMapper.mapList(response.results)
        let hasMorePages = response.page < response.totalPages
        
        return (movies: movies, hasMorePages: hasMorePages)
    }
    
    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails {
        do {
            let request = try TMDBApiEndpoint.movie(id: id).makeURLRequest()
            let movie = try await apiProvider.performRequest(request, decodeTo: MovieDetailsDTO.self)
            return MovieDetailsDTOMapper.map(movie)
        } catch ApiProviderError.failed(statusCode: 404) {
            throw MovieRepositoryError.movieNotFound(withId: id)
        }
    }
}
