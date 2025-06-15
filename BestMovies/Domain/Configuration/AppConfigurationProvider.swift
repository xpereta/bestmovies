import Foundation

struct AppConfigurationProvider: ConfigurationProvider {
    let posterBaseURL: String
    let backdropBaseURL: String
    let avatarBaseURL: String

    init(
        posterBaseURL: String = Configuration.posterBaseURL,
        backdropBaseURL: String = Configuration.backdropBaseURL,
        avatarBaseURL: String = Configuration.avatarBaseURL
    ) {
        self.posterBaseURL = posterBaseURL
        self.backdropBaseURL = backdropBaseURL
        self.avatarBaseURL = avatarBaseURL
    }
}
