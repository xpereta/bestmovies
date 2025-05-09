import Foundation

enum RMEndpoint {
    case characters(page: Int? = nil)

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "rickandmortyapi.com"
        components.path = "/api/" + path
        
        components.queryItems = queryItems
        
        return components.url
    }
    
    private var path: String {
        switch self {
        case .characters:
            return "character"
        }
    }
    
    private var queryItems: [URLQueryItem]? {
        switch self {
        case .characters(let page):
            guard let page else { return nil }
            let item = URLQueryItem(name: "page", value: String(page))
            return [item]
        }
    }
}

enum RMError: Error {
    case invalidURL
    case invalidResponse
    case invalidStatusCode
    case networkError(Error)
    case decodingError(Error)
}

final class RMAPIClient {
    private let session: URLSession
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    func fetch<T: Decodable>(_ endpoint: RMEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw RMError.invalidURL
        }
        print("API: \(url)")
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RMError.invalidResponse
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw RMError.invalidStatusCode
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw RMError.decodingError(error)
        } catch {
            throw RMError.networkError(error)
        }
    }
}
