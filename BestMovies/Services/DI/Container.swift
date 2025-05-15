import FactoryKit
import Foundation

extension Container {
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

    var getMoviesRepository: Factory<MovieRepositoryType> {
        Factory(self) {
            let apiConfiguration = TMDBConfiguration(baseURL: "https://api.themoviedb.org/3", apiKey: "97d24ffef95aebe28225de0c524590d9")
            return MovieRepository(apiClient: self.apiClient(apiConfiguration))
        }
    }

    var apiClient: ParameterFactory<TMDBConfiguration, TMDBAPI.ClientType> {
        self {
            return TMDBAPI.Client(apiProvider: self.apiProvider(), apiConfiguration: $0)
        }
        .cached
    }

    var apiProvider: Factory<ApiProvider> {
        self { URLSessionApiProvider(urlSession: URLSession.shared) }
            .cached
    }
}
