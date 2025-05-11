import Foundation

public final class URLSessionApiProvider: ApiProvider {
    private let urlSession: URLSession
//    private let logger: = appLogger(categoryFor: URLSessionApiProvider.self)

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    public func performRequest(
        _ urlRequest: URLRequest,
        delegate: URLSessionTaskDelegate? = nil,
    ) async throws -> (data: Data, urlResponse: URLResponse) {
        guard let stringURL = urlRequest.url?.absoluteString else {
            print("🚨 Invalid URL for request: \(urlRequest.description)")
            throw ApiProviderError.invalidURL
        }
        
        print("🎬 Performing request: \(stringURL)")

        let (data, response) = try await urlSession.data(for: urlRequest, delegate: delegate)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("🚨 Invalid response: \(response.description)")
            throw ApiProviderError.invalidResponse
        }
        
        let responseData = String(data: data, encoding: .utf8) ?? "n/a"
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("🚨 Request failed with status code \(httpResponse.statusCode)")
            throw ApiProviderError.failed(statusCode: httpResponse.statusCode)
        }
        
        print("✅ Request succeeded with status code \(httpResponse.statusCode), URL: \(stringURL)")
        
        return (data, response)
    }
}
