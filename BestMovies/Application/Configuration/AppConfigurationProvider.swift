import BestMoviesDomain
import Foundation

public struct AppConfigurationProvider: ConfigurationProvider {
    public let posterBaseURL: String
    public let backdropBaseURL: String
    public let avatarBaseURL: String

    public init(
        posterBaseURL: String,
        backdropBaseURL: String,
        avatarBaseURL: String
    ) {
        self.posterBaseURL = posterBaseURL
        self.backdropBaseURL = backdropBaseURL
        self.avatarBaseURL = avatarBaseURL
    }
}
