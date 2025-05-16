import Foundation

protocol ApiProvider {
    func performRequest(
        _ urlRequest: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (data: Data, urlResponse: URLResponse)
}

extension ApiProvider {
    func performRequest<T: Decodable>(
        _ urlRequest: URLRequest,
        delegate: URLSessionTaskDelegate? = nil,
        decodeTo resultType: T.Type,
        decoder: JSONDecoder = JSONDecoder(),
    ) async throws -> T {
        let data = try await performRequest(urlRequest, delegate: delegate).data

        do {
            let decoded = try decoder.decode(resultType, from: data)
            return decoded
        } catch let error {
#if DEBUG
            print("🚨 ApiProvider, decoding error: \(error)")
#endif
            throw ApiProviderError.decodingFailed
        }
    }
}
