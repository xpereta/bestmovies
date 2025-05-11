import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case failed(statusCode: Int)
    case decodingError(Error)
}

protocol TMDBAPIClientProtocol {
    func fetchMovies(page: Int) async throws -> MovieResponse
    func searchMovies(query: String, page: Int) async throws -> MovieResponse
}

final class TMDBAPIClient: TMDBAPIClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchMovies(page: Int) async throws -> MovieResponse {
        guard let url = TMDBApiConfiguration.Endpoint.topRated(page: page).url else {
            throw NetworkError.invalidURL
        }
        
        return try await fetch(url: url)
    }
    
    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        guard let url = TMDBApiConfiguration.Endpoint.searchMovies(query: query, page: page).url else {
            throw NetworkError.invalidURL
        }
        
        return try await fetch(url: url)
    }
    
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.failed(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
