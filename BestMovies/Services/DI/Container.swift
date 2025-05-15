import Foundation
import FactoryKit

extension Container {
    var getMoviesUseCase: Factory<GetMoviesUseCaseProtocol> {
        Factory(self) {
            GetMoviesUseCase(repository: self.getMoviesRepository())
        }
    }

    var getMovieDetailsUseCase: Factory<GetMovieDetailsUseCaseProtocol> {
        Factory(self) {
            GetMovieDetailsUseCase(repository: self.getMoviesRepository())
        }
    }

    var getMoviesRepository: Factory<MovieRepositoryProtocol> {
        Factory(self) {
            let apiConfiguration = TMDBConfiguration(baseURL: "https://api.themoviedb.org/3", apiKey: "97d24ffef95aebe28225de0c524590d9")
            return MovieRepository(apiClient: self.apiClient(apiConfiguration))
        }
    }

    var apiClient: ParameterFactory<TMDBConfiguration, TMDBAPI.ClientProtocol> {
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
