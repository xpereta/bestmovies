import Foundation
import Networking

public struct TMDBConfiguration {
    public let baseURL: String
    public let apiKey: String

    public init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
}

public extension TMDBAPI {
    enum Endpoint: ApiEndpoint {
        case topRated(page: Int, configuration: TMDBConfiguration)
        case searchMovies(query: String, page: Int, configuration: TMDBConfiguration)
        case movie(id: Int, configuration: TMDBConfiguration)
        case movieReviews(movieId: Int, configuration: TMDBConfiguration)

        public var baseURL: String {
            switch self {
            case .topRated(page: _, configuration: let configuration),
                 .searchMovies(query: _, page: _, configuration: let configuration),
                 .movie(id: _, configuration: let configuration),
                 .movieReviews(movieId: _, configuration: let configuration):
                return configuration.baseURL
            }
        }

        public var path: String {
            switch self {
            case .topRated:
                return "/movie/top_rated"
            case .searchMovies:
                return "/search/movie"
            case .movie(id: let id, _):
                return "/movie/\(id)"
            case .movieReviews(movieId: let id, _):
                return "/movie/\(id)/reviews"
            }
        }

        public var queryItems: [URLQueryItem] {
            var items = [URLQueryItem]()

            switch self {
            case .topRated(let page, let configuration):
                items.append(URLQueryItem(name: "api_key", value: configuration.apiKey))
                items.append(URLQueryItem(name: "page", value: String(page)))
            case .searchMovies(let query, let page, let configuration):
                items.append(URLQueryItem(name: "api_key", value: configuration.apiKey))
                items.append(contentsOf: [
                    URLQueryItem(name: "query", value: query),
                    URLQueryItem(name: "page", value: String(page))
                ])
            case .movie(_, let configuration),
                 .movieReviews(_, let configuration):
                items.append(URLQueryItem(name: "api_key", value: configuration.apiKey))
            }

            return items
        }
    }
}
