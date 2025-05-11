import Foundation

public protocol ApiEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

public extension ApiEndpoint {
    private var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
    
    func makeURLRequest() throws -> URLRequest {
        guard let url else {
            throw ApiProviderError.invalidURL
        }
        let urlRequest = URLRequest(url: url)
        return urlRequest
    }
}
