import TMDBAPI

class TMDBAPIClientSpy: TMDBAPI.ClientType {
    var movieResponseToReturn: TMDBAPI.DTO.MovieResponse?
    var movieDetailsToReturn: TMDBAPI.DTO.MovieDetails?
    var reviewsResponseToReturn: TMDBAPI.DTO.ReviewResponse?
    var errorToThrow: Error?

    var fetchMoviesCallCount = 0
    var lastPageRequested: Int?
    var lastQueryRequested: String?

    var fetchMovieDetailsCallCount = 0
    var fetchReviewsCallCount = 0

    var lastMovieIdRequested: Int?

    func fetchMovies(page: Int, query: String?) async throws -> TMDBAPI.DTO.MovieResponse {
        fetchMoviesCallCount += 1
        lastPageRequested = page
        lastQueryRequested = query

        if let error = errorToThrow {
            throw error
        }

        return movieResponseToReturn ?? TMDBAPI.DTO.MovieResponse(page: 1, results: [], totalPages: 1)
    }

    func fetchMovieDetails(_ id: Int) async throws -> TMDBAPI.DTO.MovieDetails {
        fetchMovieDetailsCallCount += 1
        lastMovieIdRequested = id

        if let error = errorToThrow {
            throw error
        }

        return movieDetailsToReturn ?? TMDBAPI.DTO.MovieDetails(
            id: id,
            title: "",
            overview: "",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "",
            voteAverage: 0,
            voteCount: 0,
            runtime: nil,
            genres: [],
            status: "",
            tagline: nil,
            budget: 0,
            revenue: 0,
            originalLanguage: "en"
        )
    }

    func fetchMovieReviews(movieId: Int) async throws -> TMDBAPI.DTO.ReviewResponse {
        fetchReviewsCallCount += 1

        if let error = errorToThrow {
            throw error
        }

        return reviewsResponseToReturn ?? TMDBAPI.DTO.ReviewResponse(results: [])
    }
}
