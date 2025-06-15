import BestMoviesDomain
import Movies

struct AppMoviesDependencies: MoviesDependencies {
    var getMoviesUseCase: GetMoviesUseCaseType
    var getMovieDetailsUseCase: GetMovieDetailsUseCaseType
    var getReviewsUseCase: GetReviewsUseCaseType
}
