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
        let response: TMDBAPI.DTO.MovieResponse
        let request: URLRequest
        
        if let query = query, !query.isEmpty {
            request = try TMDBAPI.Endpoint.searchMovies(query: query, page: page).makeURLRequest()
        } else {
            request = try TMDBAPI.Endpoint.topRated(page: page).makeURLRequest()
        }
        
        response = try await apiProvider.performRequest(request, decodeTo: TMDBAPI.DTO.MovieResponse.self)
        
        let movies = MovieDTOMapper.mapList(response.results)
        let hasMorePages = response.page < response.totalPages
        
        return (movies: movies, hasMorePages: hasMorePages)
    }
    
    func fetchMovieDetails(_ id: Int) async throws -> MovieDetails {
        do {
            let request = try TMDBAPI.Endpoint.movie(id: id).makeURLRequest()
            let movie = try await apiProvider.performRequest(request, decodeTo: TMDBAPI.DTO.MovieDetails.self)
            return MovieDetailsDTOMapper.map(movie)
        } catch ApiProviderError.failed(statusCode: 404) {
            throw MovieRepositoryError.movieNotFound(withId: id)
        }
    }
}
