import Quick
import Nimble
@testable import BestMovies

//class RMEndpointSpec: QuickSpec {
//    override class func spec() {
//        describe("RMEnpoint") {
//            context("when creating URLs") {
//                it("should create the correct URL for the characters endpoint") {
//                    let endpoint = RMEndpoint.characters
//                    expect(endpoint.url?.absoluteString) == "https://rickandmortyapi.com/api/character"
//                }
//            }
//        }
//        These would be redundant to check again
//        context("when checking path components") {
//            it("should have the correct scheme") {
//                let endpoint = RMEndpoint.characters
//                expect(endpoint.url?.scheme) == "https"
//            }
//            
//            it("should have the correct host") {
//                let endpoint = RMEndpoint.characters
//                expect(endpoint.url?.host) == "rickandmortyapi.com"
//            }
//            
//            it("should have the correct path") {
//                let endpoint = RMEndpoint.characters
//                expect(endpoint.url?.path) == "/api/character"
//            }
//        }
//    }
//}

//class RMAPIClientSpec: AsyncSpec {
//    override class func spec() {
//        describe("RMAPIClient") {
//            context("when requesting characters") {
//                it("should return 20 characters") {
//                    let apiClient = RMAPIClient()
//                    await expect {
//                        let response:CharacterResponse = try await apiClient.fetch(.characters)
//                        return response.results.count
//                    }.to(equal(20))
//                }
//            }
//        }
//    }
//}
//
