enum ApiProviderError: Error {
    case invalidURL
    case invalidResponse
    case failed(statusCode: Int)
    case decodingFailed
}
