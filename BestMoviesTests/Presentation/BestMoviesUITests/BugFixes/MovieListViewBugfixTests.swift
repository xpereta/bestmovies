import XCTest

final class MovieListViewBugfixTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    /// Bug in the search results not updating when clearing search text
    ///
    /// Steps to reproduce:
    /// 1 - The movie list displays the default results for all movies without filter
    /// 2 - Enter a search text that does not match any movie
    /// 3 - The list displays no results and the the no movies found text
    /// 4 - Clear the search text
    /// Expected result:
    /// - The list displays all movies without filter
    /// Actual result:
    /// - The list still still displays the no movies found text
    func test_givenSearchText_whenCleared_thenAllMoviesAreShown() throws {
        // Given
        let textField = app.textFields["Search movies..."]

        // When
        textField.tap()
        textField.typeText("Non existing movie 123456")

        // Then
        let notFoundText = app.staticTexts["Sorry, no movies found"]
        XCTAssertTrue(notFoundText.waitForExistence(timeout: 2))

        // When
        let clearSearchButton = app.buttons["Close"]
        clearSearchButton.tap()

        // Then
        XCTAssertTrue(notFoundText.waitForNonExistence(timeout: 2))
    }
}
