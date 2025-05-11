import Foundation

struct MovieDetails: Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: Date?
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [Genre]
    let status: String
    let tagline: String?
    let budget: Int
    let revenue: Int
    let originalLanguage: String
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }
    
    var runtimeFormatted: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)h \(minutes)m"
    }
}
