import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel: MovieListViewModel
    
    init() {
        let apiConfiguration = TMDBConfiguration(baseURL: "https://api.themoviedb.org/3", apiKey: "97d24ffef95aebe28225de0c524590d9")

        let repository = MovieRepository(apiConfiguration: apiConfiguration)
        let useCase = GetMoviesUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: MovieListViewModel(getMoviesUseCase: useCase))
    }
    
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
            .task() {
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
            .resizable()
            .foregroundStyle(.gray)
            .opacity(0.6)
    }
}

struct MovieRow: View {
    let movie: Movie
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        Button {
            coordinator.push(page: .movieDetails(movie.id))
        } label: {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MovieListView()
}
