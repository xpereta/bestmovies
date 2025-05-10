import Foundation

enum RMEndpoint {
    case characters(page: Int? = nil, name: String? = nil)
    case character(id: Int)

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
        case .character(let id):
            return "character/\(id)"
        }
    }
    
    private var queryItems: [URLQueryItem]? {
        switch self {
        case .characters(let page, let name):
            var items: [URLQueryItem] = []
            if let page { items.append(URLQueryItem(name: "page", value: String(page))) }
            if let name { items.append(URLQueryItem(name: "name", value: name)) }
            return items.isEmpty ? nil : items
        case .character:
            return nil
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
        try! await Task.sleep(nanoseconds: 2_000_000_000)
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
