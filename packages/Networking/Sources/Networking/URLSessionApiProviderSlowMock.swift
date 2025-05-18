import Foundation

final class URLSessionApiProviderSlowMock: ApiProvider {
    var decoratee: ApiProvider
    var delaySeconds: Double

    init(_ decoratee: ApiProvider, delaySeconds: Double = 2.0) {
        self.decoratee = decoratee
        self.delaySeconds = delaySeconds
    }

    func performRequest(_ urlRequest: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (data: Data, urlResponse: URLResponse) {
        try await Task.sleep(for: .seconds(delaySeconds))

        return try await decoratee.performRequest(urlRequest, delegate: delegate)
    }
}
