import Foundation

enum MovieRepositoryError: LocalizedError {
    case movieNotFound(withId: Int)

    var errorDescription: String? {
        switch self {
        case .movieNotFound(let withId):
            return "Movie not found with id \(withId)."
        }
    }
}
