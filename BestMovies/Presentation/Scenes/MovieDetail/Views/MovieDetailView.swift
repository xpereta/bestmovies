import SwiftUI
import UIKit

struct MovieDetailView<ViewModel>: View where ViewModel: MovieDetailViewModelType {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading movie...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let movie, let reviews):
                LoadedMovie(movie: movie, reviews: reviews)

            case .error(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .foregroundColor(.red)

                    Button("Try Again") {
                        viewModel.loadMovie()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            viewModel.loadMovie()
        }
    }
}

struct LoadedMovie: View {
    let movie: MovieDetails
    let reviews: [Review]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackdropImageSection(backdropURL: movie.backdropURL)

                VStack(alignment: .leading, spacing: 20) {
                    MovieHeaderSection(
                        title: movie.title,
                        releaseDate: movie.releaseDate,
                        tagline: movie.tagline
                    )

                    MovieStatsSection(
                        voteAverage: movie.voteAverage,
                        voteCount: movie.voteCount,
                        runtime: movie.runtimeFormatted
                    )

                    if !movie.genres.isEmpty {
                        GenresSection(genres: movie.genres)
                    }

                    if !movie.overview.isEmpty {
                        OverviewSection(overview: movie.overview)
                    }

                    ReviewsView(reviews: reviews)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
    }
}

// MARK: - SubViews

private struct BackdropImageSection: View {
    let backdropURL: URL?

    var body: some View {
        if let backDropURL = backdropURL {
            GeometryReader { geometry in
                AsyncImage(url: backDropURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        FailedImageView()
                            .aspectRatio(contentMode: .fit)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        FailedImageView()
                    }
                }
                .frame(width: geometry.size.width, height: 200)
            }
            .frame(height: 200)
            .padding(.vertical)
        }
    }
}

private struct MovieHeaderSection: View {
    let title: String
    let releaseDate: Date?
    let tagline: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.title)
                    .bold()

                if let date = releaseDate {
                    Text("(\(date, format: .dateTime.year()))")
                        .foregroundStyle(.secondary)
                }
            }

            if let tagline = tagline {
                Text(tagline)
                    .italic()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct MovieStatsSection: View {
    let voteAverage: Double
    let voteCount: Int
    let runtime: String?

    var body: some View {
        HStack(spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", voteAverage))
                Text("(\(voteCount))")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let runtime = runtime {
                Text(runtime)
            }
        }
    }
}

private struct GenresSection: View {
    let genres: [Genre]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(genres) { genre in
                    Text(genre.name)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.2))
                        )
                }
            }
        }
    }
}

private struct OverviewSection: View {
    @State private var overview: String

    init(overview: String) {
        self.overview = overview
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)
            Text($overview.wrappedValue)
                .font(.body)
        }
    }
}

struct ReviewsView: View {
    let reviews: [Review]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Reviews")
                .font(.headline)
                .padding(.vertical, 8)
            if reviews.isEmpty {
                Text("This movie does not have reviews yet")
                    .font(.footnote)
            } else {
                ForEach(reviews, id: \.id) { review in
                    ReviewCard(review: review)
                        .padding(.bottom, 8)
                }
            }
        }
    }
}

struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let avatarURL = review.authorDetails?.avatarURL {
                    AsyncImage(url: avatarURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if phase.error != nil {
                            Image(systemName: "person.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.3)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                    .clipped()
                }

                Text(review.author)
                    .font(.headline)
                Spacer()
                if let rating = review.authorDetails?.ratingFormatted {
                    Text("Rating: \(rating)")
                        .foregroundStyle(.secondary)
                }
            }
            Text(review.content)
                .font(.body)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Previews for each state

#Preview("Idle") {
    MovieDetailView(viewModel: StubMovieDetailViewModel(state: .idle))
}

#Preview("Loading") {
    MovieDetailView(viewModel: StubMovieDetailViewModel(state: .loading))
}

#Preview("Loaded") {
    let movieDetails = MovieDetails(
        id: 603,
        title: "The Matrix",
        overview: """
        Set in the 22nd century, The Matrix tells the story of a computer programmer who joins a rebellion to combat intelligent machines that have constructed a
        """ + """
                virtual reality simulation that keeps humanity under control.
        """,
        releaseDate: Date(),
        voteAverage: 8.7,
        voteCount: 24563,
        runtime: 136,
        genres: [
            Genre(id: 28, name: "Action"),
            Genre(id: 878, name: "Science Fiction")
        ],
        status: "Released",
        tagline: "Welcome to the Real World",
        budget: 63000000,
        revenue: 463517383,
        originalLanguage: "en",
        posterURL: URL(string: "https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg"),
        backdropURL: URL(string: "https://image.tmdb.org/t/p/original/l4QHerTSbMI7qgvasqxP36pqjN6.jpg")
    )

    let loadedState = MovieDetailViewModel.State.loaded(movieDetails, [])
    MovieDetailView(viewModel: StubMovieDetailViewModel(state: loadedState))
}

#Preview("Loaded with reviews") {
    let movieDetails = MovieDetails(
        id: 603,
        title: "The Matrix",
        overview: """
        Set in the 22nd century, The Matrix tells the story of a computer programmer who joins a rebellion to combat intelligent machines that have constructed a
        """ + """
                virtual reality simulation that keeps humanity under control.
        """,
        releaseDate: Date(),
        voteAverage: 8.7,
        voteCount: 24563,
        runtime: 136,
        genres: [
            Genre(id: 28, name: "Action"),
            Genre(id: 878, name: "Science Fiction")
        ],
        status: "Released",
        tagline: "Welcome to the Real World",
        budget: 63000000,
        revenue: 463517383,
        originalLanguage: "en",
        posterURL: URL(string: "https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg"),
        backdropURL: URL(string: "https://image.tmdb.org/t/p/original/l4QHerTSbMI7qgvasqxP36pqjN6.jpg")
    )

    let reviews = [
        Review(
            id: "1",
            author: "John Doe",
            content: "This is a review",
            createdAt: Date(),
            authorDetails: Review.AuthorDetails(
                name: "John Doe",
                rating: 5.5,
                avatarURL: URL(string: "https://image.tmdb.org/t/p/original/utEXl2EDiXBK6f41wCLsvprvMg4.jpg"),
            )
        ),
        Review(
            id: "2",
            author: "Jane Doe",
            content: "This is another review",
            createdAt: Date(),
            authorDetails: Review.AuthorDetails(
                name: "Jane Doe",
                rating: 7.4,
                avatarURL: URL(string: "https://image.tmdb.org/t/p/original/invalid.jpg"),
            )
        )
    ]

    let loadedState = MovieDetailViewModel.State.loaded(movieDetails, reviews)
    MovieDetailView(viewModel: StubMovieDetailViewModel(state: loadedState))
}

#Preview("Loaded, image error") {
    let movieDetails = MovieDetails(
        id: 603,
        title: "The Matrix",
        overview: """
        Set in the 22nd century, The Matrix tells the story of a computer programmer who joins a rebellion to combat intelligent
        """ + """
        machines that have constructed a virtual reality simulation that keeps humanity under control.
        """,
        releaseDate: Date(),
        voteAverage: 8.7,
        voteCount: 24563,
        runtime: 136,
        genres: [
            Genre(id: 28, name: "Action"),
            Genre(id: 878, name: "Science Fiction")
        ],
        status: "Released",
        tagline: "Welcome to the Real World",
        budget: 63000000,
        revenue: 463517383,
        originalLanguage: "en",
        posterURL: URL(string: "https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg"),
        backdropURL: URL(string: "https://image.tmdb.org/t/p/original/error.jpg")
    )

    let loadedState = MovieDetailViewModel.State.loaded(movieDetails, [])
    MovieDetailView(viewModel: StubMovieDetailViewModel(state: loadedState))
}

#Preview("Error") {
    MovieDetailView(viewModel: StubMovieDetailViewModel(state: .error("Sorry, something went wrong")))
}
