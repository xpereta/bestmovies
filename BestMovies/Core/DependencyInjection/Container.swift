import FactoryKit
import Foundation
import Networking
import TMDBAPI
import Domain

extension Container {
    var configurationProvider: Factory<ConfigurationProvider> {
        self { AppConfigurationProvider(posterBaseURL: Configuration.posterBaseURL, backdropBaseURL: Configuration.backdropBaseURL, avatarBaseURL: Configuration.avatarBaseURL) }
            .cached
    }

    var getMoviesUseCase: Factory<GetMoviesUseCaseType> {
        Factory(self) {
            GetMoviesUseCase(repository: self.getMoviesRepository())
        }
    }

    var getMovieDetailsUseCase: Factory<GetMovieDetailsUseCaseType> {
        Factory(self) {
            GetMovieDetailsUseCase(repository: self.getMoviesRepository())
        }
    }

    var getReviewsUseCase: Factory<GetReviewsUseCaseType> {
        Factory(self) {
            GetReviewsUseCase(repository: self.getMoviesRepository())
        }
    }

    var getMoviesRepository: Factory<MovieRepositoryType> {
        Factory(self) {
            let apiConfiguration = TMDBConfiguration(
                baseURL: Configuration.apiBaseURL,
                apiKey: Configuration.apiKey
            )

            return MovieRepository(
                apiClient: self.apiClient(apiConfiguration),
                configurationProvider: self.configurationProvider()
            )
        }
    }

    var apiClient: ParameterFactory<TMDBConfiguration, TMDBAPI.ClientType> {
        self {
            TMDBAPI.Client(apiProvider: self.apiProvider(), apiConfiguration: $0)
        }
        .cached
    }

    var apiProvider: Factory<ApiProvider> {
        self {
            URLSessionApiProvider(urlSession: URLSession.shared)
        }
        .cached
    }
}
