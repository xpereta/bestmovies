import SwiftUI
import Combine

struct MovieListView: View {
    @StateObject private var viewModel = MovieListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                    .autocorrectionDisabled()
                
                Group {
                    switch viewModel.state {
                    case .idle:
                        EmptyView()
                    case .loading:
                        ProgressView("Loading...")
                    case .loaded(let movies, _, let hasMore, let isLoadingMore):
                        moviesList(movies: movies, hasMore: hasMore, isLoadingMore: isLoadingMore)
                    case .error(let message):
                        Text(message)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Best Movies")
            .onDisappear {
                viewModel.onDissapear()
            }
            .task {
                viewModel.startLoading()
            }
        }
    }
    
    @ViewBuilder
    private func moviesList(movies: [Movie], hasMore: Bool, isLoadingMore: Bool) -> some View {
        List {
            ForEach(movies) { movie in
                MovieRow(movie: movie)
            }
            if hasMore {
                HStack {
                    ProgressView("Loading more...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .onAppear {
                    if !isLoadingMore {
                        viewModel.loadNextPage()
                    }
                }
            }
        }
        .animation(.default, value: movies)
        .overlay {
            if movies.isEmpty {
                VStack {
                    Spacer()
                    Text("Sorry, no movies found")
                    Image(systemName: "magnifyingglass")
                    Spacer()
                }
            }
        }
    }
}

struct FailedImage: View {
    let systemName: String
    
    init(systemName: String = "film") {
        self.systemName = systemName
    }
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundStyle(.gray)
    }
}

struct MovieRow: View {
    let movie: Movie
    
    var body: some View {
        NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
            HStack(spacing: 12) {
                AsyncImage(url: movie.posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        FailedImage()
                    case .empty:
                        ProgressView()
                    @unknown default:
                        FailedImage()
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.headline)
                    
                    if let date = movie.releaseDate {
                        Text(date, format: .dateTime.year())
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", movie.voteAverage))
                            .font(.subheadline)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    MovieListView()
}
