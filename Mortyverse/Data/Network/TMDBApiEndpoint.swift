import Foundation

enum TMDBApiEndpoint: ApiEndpoint {
    #warning("Explain how to secure this API key")
    enum Configuration {
        static let apiKey = "97d24ffef95aebe28225de0c524590d9"
        static let baseURL = "https://api.themoviedb.org/3"
    }
    
    case topRated(page: Int)
    case searchMovies(query: String, page: Int)
    case movie(id: Int)
    
    var baseURL: String {
        Configuration.baseURL
    }
    
    var path: String {
        switch self {
        case .topRated:
            return "/movie/top_rated"
        case .searchMovies:
            return "/search/movie"
        case .movie(id: let id):
            return "/movie/\(id)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "api_key", value: Configuration.apiKey)
        ]
        
        switch self {
        case .topRated(let page):
            items.append(URLQueryItem(name: "page", value: String(page)))
        case .searchMovies(let query, let page):
            items.append(contentsOf: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ])
        case .movie:
            break
        }
        
        return items
    }
}
