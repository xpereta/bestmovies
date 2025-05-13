import SwiftUI

struct MovieDetailView<ViewModel>: View where ViewModel: MovieDetailViewModelProtocol {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading movie...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded(let movie):
                VStack(alignment: .leading) {
                    if let backDropURL = movie.backdropURL {
                        AsyncImage(url: backDropURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 300)                                    
                            case .failure:
                                FailedImage()
                                    .frame(height: 300)
                            case .empty:
                                ProgressView()
                                    .frame(height: 300)
                            @unknown default:
                                FailedImage()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text(movie.title)
                                .font(.title)
                                .bold()
                            
                            if let date = movie.releaseDate {
                                Text("(\(date, format: .dateTime.year()))")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    if let tagline = movie.tagline {
                        Text(tagline)
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", movie.voteAverage))
                            Text("(\(movie.voteCount))")
                                .foregroundStyle(.secondary)
                        }
                        
                        if let runtime = movie.runtimeFormatted {
                            Text(runtime)
                        }
                    }
                    
                    if !movie.genres.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(movie.genres) { genre in
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
                    
                    if !movie.overview.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Overview")
                                .font(.headline)
                            Text(movie.overview)
                        }
                    }
                }
                
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
        .onAppear {
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

#Preview("Error") {
    MovieDetailView(viewModel: StubMovieDetailViewModel(state: .error("Sorry, something went wrong")))
}
