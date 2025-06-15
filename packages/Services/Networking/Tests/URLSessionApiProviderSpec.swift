import Foundation
@testable import Networking
import Nimble
import Quick

final class URLSessionApiProviderSpec: AsyncSpec {
    // swiftlint:disable:next function_body_length
    override static func spec() {
        describe("URLSessionApiProvider") {
            var sut: URLSessionApiProvider!
            var mockSession: MockURLSession!
            let validURL = URL(string: "https://api.example.com/test")!

            beforeEach {
                mockSession = MockURLSession()
                sut = URLSessionApiProvider(urlSession: mockSession)
            }

            context("when performing a request") {
                context("with valid URL and successful response") {
                    it("returns the expected data") {
                        let expectedData = Data("test data".utf8)
                        let response = HTTPURLResponse(
                            url: validURL,
                            statusCode: 200,
                            httpVersion: nil,
                            headerFields: nil
                        )!

                        mockSession.mockData = expectedData
                        mockSession.mockResponse = response

                        let request = URLRequest(url: validURL)

                        await expect { try await sut.performRequest(request).data }.to(equal(expectedData))
                    }
                }

                context("with non-HTTP response") {
                    it("throws invalidResponse error") {
                        mockSession.mockResponse = URLResponse()
                        let request = URLRequest(url: validURL)

                        await expect { try await sut.performRequest(request) }
                            .to(throwError(ApiProviderError.invalidResponse))
                    }
                }

                context("with not found status code") {
                    it("throws failed error with not found status code") {
                        let errorResponse = HTTPURLResponse(
                            url: validURL,
                            statusCode: 404,
                            httpVersion: nil,
                            headerFields: nil
                        )!
                        mockSession.mockResponse = errorResponse
                        let request = URLRequest(url: validURL)

                        await expect { try await sut.performRequest(request) }
                            .to(throwError(ApiProviderError.failed(statusCode: 404)))
                    }
                }

                context("with server error status code") {
                    it("throws failed error with server error status code") {
                        let errorResponse = HTTPURLResponse(
                            url: validURL,
                            statusCode: 500,
                            httpVersion: nil,
                            headerFields: nil
                        )!
                        mockSession.mockResponse = errorResponse
                        let request = URLRequest(url: validURL)

                        await expect { try await sut.performRequest(request) }
                            .to(throwError(ApiProviderError.failed(statusCode: 404)))
                    }
                }

                context("when not connected to internet error occurs") {
                    it("propagates the error") {
                        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
                        mockSession.mockError = networkError
                        let request = URLRequest(url: validURL)

                        await expect { try await sut.performRequest(request) }.to(throwError())
                    }
                }
            }
        }
    }
}

private class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        return (mockData ?? Data(), mockResponse ?? URLResponse())
    }
}
