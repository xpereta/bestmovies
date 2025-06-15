import BestMoviesDomain

struct TestConfigurationProvider: ConfigurationProvider {
    var posterBaseURL: String
    var backdropBaseURL: String
    var avatarBaseURL: String

    init(
        posterBaseURL: String = "https://image.tmdb.org/t/p/w200",
        backdropBaseURL: String = "https://image.tmdb.org/t/p/w500",
        avatarBaseURL: String = "https://image.tmdb.org/t/p/w200"
    ) {
        self.posterBaseURL = posterBaseURL
        self.backdropBaseURL = backdropBaseURL
        self.avatarBaseURL = avatarBaseURL
    }
}
