import SwiftUI

struct MovieListView<ViewModel>: View where ViewModel: MovieListViewModelProtocol {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
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
                        Spacer()
                        ProgressView("Loading...")
                        Spacer()
                    case .loaded(let movies, _, let hasMore, let isLoadingMore):
                        moviesList(movies: movies, hasMore: hasMore, isLoadingMore: isLoadingMore)
                    case .error(let message):
                        Spacer()
                        Text(message)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                Spacer()
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
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Sorry, no movies found")
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - SubViews

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
                        FailedImageView()
                    case .empty:
                        ProgressView()
                    @unknown default:
                        FailedImageView()
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

// MARK: - Previews for each state

#Preview("idle") {
    let viewModel = StubMovieListViewModel(state: .idle)
    MovieListView(viewModel: viewModel)
}

#Preview("loading") {
    let viewModel = StubMovieListViewModel(state: .loading)
    MovieListView(viewModel: viewModel)
}

#Preview("loaded, end of pages") {
    let sampleMovies = [
        Movie(
            id: 1,
            title: "Inception",
            overview: "A thief who enters dreams",
            posterPath: "/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
            releaseDate: Date(timeIntervalSince1970: 1279238400),
            voteAverage: 8.4,
        ),
        Movie(
            id: 2,
            title: "The Dark Knight",
            overview: "Batman fights the Joker",
            posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
            releaseDate: Date(timeIntervalSince1970: 1216166400),
            voteAverage: 8.9,
        ),
        Movie(
            id: 3,
            title: "Pulp Fiction",
            overview: "Multiple interrelated stories",
            posterPath: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
            releaseDate: Date(timeIntervalSince1970: 781401600),
            voteAverage: 8.5,
        )
    ]
    
    let viewModel = StubMovieListViewModel(
        state: .loaded(sampleMovies, currentPage: 1, hasMore: false, isLoadingMore: false)
    )
    MovieListView(viewModel: viewModel)
}

#Preview("loaded, has more pages") {
    let sampleMovies = [
        Movie(
            id: 1,
            title: "Inception",
            overview: "A thief who enters dreams",
            posterPath: "/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
            releaseDate: Date(timeIntervalSince1970: 1279238400),
            voteAverage: 8.4,
        ),
        Movie(
            id: 2,
            title: "The Dark Knight",
            overview: "Batman fights the Joker",
            posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
            releaseDate: Date(timeIntervalSince1970: 1216166400),
            voteAverage: 8.9,
        ),
        Movie(
            id: 3,
            title: "Pulp Fiction",
            overview: "Multiple interrelated stories",
            posterPath: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
            releaseDate: Date(timeIntervalSince1970: 781401600),
            voteAverage: 8.5,
        )
    ]
    
    let viewModel = StubMovieListViewModel(
        state: .loaded(sampleMovies, currentPage: 1, hasMore: true, isLoadingMore: false)
    )
    MovieListView(viewModel: viewModel)
}

#Preview("loaded, not found") {
    let viewModel = StubMovieListViewModel(
        state: .loaded([], currentPage: 1, hasMore: false, isLoadingMore: false), searchText: "Not a movie"
    )
    MovieListView(viewModel: viewModel)
}

#Preview("error") {
    let viewModel = StubMovieListViewModel(state: .error("Sorry, something went wrong"))
    MovieListView(viewModel: viewModel)
}

#Preview("Movie row") {
    let movie = Movie(
        id: 1,
        title: "Inception",
        overview: "A thief who enters dreams",
        posterPath: "/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
        releaseDate: Date(timeIntervalSince1970: 1279238400),
        voteAverage: 8.4,
    )
    List {
        MovieRow(movie: movie)
    }
}
