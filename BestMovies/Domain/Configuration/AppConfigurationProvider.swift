import Foundation

struct AppConfigurationProvider: ConfigurationProvider {
    var posterBaseURL: String { Configuration.posterBaseURL }
    var backdropBaseURL: String { Configuration.backdropBaseURL }
    var avatarBaseURL: String { Configuration.avatarBaseURL }
} 