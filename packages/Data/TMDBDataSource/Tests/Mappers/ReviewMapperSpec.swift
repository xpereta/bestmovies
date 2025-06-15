import Foundation
import Nimble
import Quick
import TMDBAPI
@testable import TMDBDataSource

class ReviewMapperSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("ReviewMapper") {
            var configurationProvider: TestConfigurationProvider!

            beforeEach {
                configurationProvider = TestConfigurationProvider()
            }

            context("when mapping a single review") {
                context("with all properties") {
                    it("maps all properties correctly") {
                        let authorDetailsDTO = TMDBAPI.DTO.AuthorDetails(
                            name: "John Doe",
                            avatarPath: "/avatar.jpg",
                            rating: 8.5
                        )

                        let dto = TMDBAPI.DTO.Review(
                            id: "123",
                            author: "johndoe",
                            content: "Great movie!",
                            createdAt: "2024-01-15",
                            authorDetails: authorDetailsDTO
                        )

                        let review = ReviewMapper(configurationProvider: configurationProvider).map(dto)

                        expect(review.id).to(equal("123"))
                        expect(review.author).to(equal("johndoe"))
                        expect(review.content).to(equal("Great movie!"))

                        // Date validation
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day], from: review.createdAt!)
                        expect(components.year).to(equal(2024))
                        expect(components.month).to(equal(1))
                        expect(components.day).to(equal(15))

                        // Author details validation
                        expect(review.authorDetails).toNot(beNil())
                        expect(review.authorDetails?.name).to(equal("John Doe"))
                        expect(review.authorDetails?.avatarURL?.absoluteString).to(equal("https://image.tmdb.org/t/p/w200/avatar.jpg"))
                        expect(review.authorDetails?.rating).to(equal(8.5))
                    }
                }

                context("without author details") {
                    it("maps with nil author details") {
                        let dto = TMDBAPI.DTO.Review(
                            id: "123",
                            author: "johndoe",
                            content: "Great movie!",
                            createdAt: "2024-01-15",
                            authorDetails: nil
                        )

                        let review = ReviewMapper(configurationProvider: configurationProvider).map(dto)

                        expect(review.authorDetails).to(beNil())
                    }
                }

                context("with invalid date") {
                    it("maps with nil creation date") {
                        let dto = TMDBAPI.DTO.Review(
                            id: "123",
                            author: "johndoe",
                            content: "Great movie!",
                            createdAt: "invalid-date",
                            authorDetails: nil
                        )

                        let review = ReviewMapper(configurationProvider: configurationProvider).map(dto)

                        expect(review.createdAt).to(beNil())
                    }
                }
            }

            context("when mapping multiple reviews") {
                it("maps all reviews correctly") {
                    let dtos = [
                        TMDBAPI.DTO.Review(
                            id: "123",
                            author: "user1",
                            content: "First review",
                            createdAt: "2024-01-15",
                            authorDetails: nil
                        ),
                        TMDBAPI.DTO.Review(
                            id: "456",
                            author: "user2",
                            content: "Second review",
                            createdAt: "2024-01-16",
                            authorDetails: nil
                        )
                    ]

                    let reviews = ReviewMapper(configurationProvider: configurationProvider).mapList(dtos)

                    expect(reviews).to(haveCount(2))
                    expect(reviews[0].id).to(equal("123"))
                    expect(reviews[1].id).to(equal("456"))
                }

                it("returns empty array when given empty input") {
                    let reviews = ReviewMapper(configurationProvider: configurationProvider).mapList([])
                    expect(reviews).to(beEmpty())
                }
            }

            context("AuthorDetailsMapper") {
                it("maps author details correctly") {
                    let dto = TMDBAPI.DTO.AuthorDetails(
                        name: "John Doe",
                        avatarPath: "/avatar.jpg",
                        rating: 8.5
                    )

                    let authorDetails = ReviewMapper.AuthorDetailsMapper.map(dto, configurationProvider: configurationProvider)

                    expect(authorDetails.name).to(equal("John Doe"))
                    expect(authorDetails.avatarURL?.absoluteString).to(equal("https://image.tmdb.org/t/p/w200/avatar.jpg"))
                    expect(authorDetails.rating).to(equal(8.5))
                }
            }
        }
    }
}
