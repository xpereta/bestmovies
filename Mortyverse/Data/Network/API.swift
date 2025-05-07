import Foundation

enum RMEndpoint {
    case characters
    //    case character(id: Int)
    //    case locations
    //    case episodes

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "rickandmortyapi.com"
        components.path = "/api/" + path
        
        return components.url
    }
    
    private var path: String {
        switch self {
        case .characters:
            return "character"
        }
    }
}

enum RMError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

final class RMAPIClient {
    private let session: URLSession
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
    }
    
    func fetch<T: Decodable>(_ endpoint: RMEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw RMError.invalidURL
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw RMError.decodingError(error)
        } catch {
            throw RMError.networkError(error)
        }
    }
}
