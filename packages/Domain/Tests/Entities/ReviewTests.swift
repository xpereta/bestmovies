@testable import Domain
import Foundation
import Testing

final class ReviewTests {

    @Test("Review initialization with all properties")
    func testReviewInitialization() {
        let date = Date()
        let avatarURL = URL(string: "https://example.com/avatar.jpg")
        let authorDetails = Review.AuthorDetails(
            name: "John Doe",
            rating: 8.5,
            avatarURL: avatarURL
        )

        let review = Review(
            id: "review1",
            author: "John Doe",
            content: "Great movie!",
            createdAt: date,
            authorDetails: authorDetails
        )

        #expect(review.id == "review1")
        #expect(review.author == "John Doe")
        #expect(review.content == "Great movie!")
        #expect(review.createdAt == date)
        #expect(review.authorDetails?.name == "John Doe")
        #expect(review.authorDetails?.rating == 8.5)
        #expect(review.authorDetails?.avatarURL == avatarURL)
    }

    @Test("Review initialization with nil values")
    func testReviewInitializationWithNilValues() {
        let review = Review(
            id: "review1",
            author: "John Doe",
            content: "Great movie!",
            createdAt: nil,
            authorDetails: nil
        )

        #expect(review.id == "review1")
        #expect(review.author == "John Doe")
        #expect(review.content == "Great movie!")
        #expect(review.createdAt == nil)
        #expect(review.authorDetails == nil)
    }

    @Test("AuthorDetails rating formatting")
    func testAuthorDetailsRatingFormatting() {
        let authorDetails1 = Review.AuthorDetails(
            name: "John Doe",
            rating: 8.5,
            avatarURL: nil
        )

        let authorDetails2 = Review.AuthorDetails(
            name: "Jane Smith",
            rating: 7.0,
            avatarURL: nil
        )

        let authorDetails3 = Review.AuthorDetails(
            name: "Bob Wilson",
            rating: nil,
            avatarURL: nil
        )

        #expect(authorDetails1.ratingFormatted == "8.5")
        #expect(authorDetails2.ratingFormatted == "7.0")
        #expect(authorDetails3.ratingFormatted == nil)
    }

    @Test("Review equality comparison")
    func testReviewEquality() {
        let review1 = Review(
            id: "review1",
            author: "John Doe",
            content: "Great movie!",
            createdAt: nil,
            authorDetails: nil
        )

        let review2 = Review(
            id: "review1",
            author: "Jane Smith", // Different author
            content: "Terrible movie!", // Different content
            createdAt: Date(), // Different date
            authorDetails: Review.AuthorDetails( // Different author details
                name: "Jane Smith",
                rating: 2.0,
                avatarURL: URL(string: "https://example.com/avatar.jpg")
            )
        )

        let review3 = Review(
            id: "review2", // Different ID
            author: "John Doe",
            content: "Great movie!",
            createdAt: nil,
            authorDetails: nil
        )

        // Reviews with same ID should be equal regardless of other properties
        #expect(review1 == review2)
        // Reviews with different IDs should not be equal
        #expect(review1 != review3)
    }
}
