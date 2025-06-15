import Foundation

public enum MovieRepositoryError: LocalizedError {
    case movieNotFound(withId: Int)

    public var errorDescription: String? {
        switch self {
        case .movieNotFound(let withId):
            return "Movie not found with id \(withId)."
        }
    }
}