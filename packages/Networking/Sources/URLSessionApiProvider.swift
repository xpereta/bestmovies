import Foundation

public protocol URLSessionProtocol {
    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public final class URLSessionApiProvider: ApiProvider {
    private let urlSession: URLSessionProtocol

    public init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func performRequest(
        _ urlRequest: URLRequest,
        delegate: URLSessionTaskDelegate? = nil,
    ) async throws -> (data: Data, urlResponse: URLResponse) {
        // We only need the absolute string for observability, this class is not responsible to check if the URL is valid
        let stringURL = urlRequest.url?.absoluteString ?? "n/a"
        print("🎬 Performing request: \(stringURL)")

        let (data, response) = try await urlSession.data(for: urlRequest, delegate: delegate)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("🚨 Invalid response: \(response.description)")
            throw ApiProviderError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("🚨 Request failed with status code \(httpResponse.statusCode)")
            throw ApiProviderError.failed(statusCode: httpResponse.statusCode)
        }

        print("✅ Request succeeded with status code \(httpResponse.statusCode), URL: \(stringURL)")

        return (data, response)
    }
}
