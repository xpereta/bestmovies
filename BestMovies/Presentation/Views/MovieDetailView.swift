import SwiftUI
import UIKit

struct MovieDetailView<ViewModel>: View where ViewModel: MovieDetailViewModelProtocol {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading movie...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded(let movie):
                LoadedMovie(movie)
                
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
            print("Task started")
            viewModel.loadMovie()
        }
    }
}

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
        overview: "Set in the 22nd century, The Matrix tells the story of a computer programmer who joins a rebellion to combat intelligent machines that have constructed a virtual reality simulation that keeps humanity under control.",
        posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
        backdropPath: "/l4QHerTSbMI7qgvasqxP36pqjN6.jpg",
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
        originalLanguage: "en"
    )

    let loadedState = MovieDetailViewModel.State.loaded(movieDetails)
 MovieDetailView(viewModel: StubMovieDetailViewModel(state: loadedState))
}

#Preview("Loaded, image error") {
    let movieDetails = MovieDetails(
        id: 603,
        title: "The Matrix",
        overview: "Set in the 22nd century, The Matrix tells the story of a computer programmer who joins a rebellion to combat intelligent machines that have constructed a virtual reality simulation that keeps humanity under control.",
        posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
        backdropPath: "/error.jpg",
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
        originalLanguage: "en"
    )

    let loadedState = MovieDetailViewModel.State.loaded(movieDetails)
 MovieDetailView(viewModel: StubMovieDetailViewModel(state: loadedState))
}

#Preview("Error") {
    MovieDetailView(viewModel: StubMovieDetailViewModel(state: .error("Sorry, something went wrong")))
}

struct LoadedMovie: View {
    private let movie: MovieDetails
    
    init(_ movie: MovieDetails) {
        self.movie = movie
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Backdrop Image Section
                BackdropImageSection(backdropURL: movie.backdropURL)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    MovieHeaderSection(
                        title: movie.title,
                        releaseDate: movie.releaseDate,
                        tagline: movie.tagline
                    )
                    
                    // Rating and Runtime Section
                    MovieStatsSection(
                        voteAverage: movie.voteAverage,
                        voteCount: movie.voteCount,
                        runtime: movie.runtimeFormatted
                    )
                    
                    // Genres Section
                    if !movie.genres.isEmpty {
                        GenresSection(genres: movie.genres)
                    }
                    
                    // Overview Section
                    if !movie.overview.isEmpty {
                        OverviewSection(overview: movie.overview)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
    }
}

// MARK: - Supporting Views
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
                        FailedImage()
                            .aspectRatio(contentMode: .fit)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        FailedImage()
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
            TextJustifiedView(text: $overview)
                .frame(height: 200)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct TextJustifiedView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textAlignment = .justified
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextJustifiedView

        init(_ parent: TextJustifiedView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

#Preview {
    BackdropImageSection(backdropURL: URL("/noimage.jpg"))
}
