import SwiftUI

struct MovieDetailView: View {
    @StateObject private var viewModel: MovieDetailViewModel
    
    init(movieId: Int) {
        let apiConfiguration = TMDBConfiguration(baseURL: "https://api.themoviedb.org/3", apiKey: "97d24ffef95aebe28225de0c524590d9")

        let repository = MovieRepository(apiConfiguration: apiConfiguration)
        let useCase = GetMovieDetailsUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movieId: movieId, useCase: useCase))
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

#warning("Create previews for all viewmodel states")

#Preview {
    MovieDetailView(movieId: 512)
}
