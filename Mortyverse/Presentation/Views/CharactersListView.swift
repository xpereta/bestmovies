import SwiftUI
import Combine

struct CharactersListView: View {
    @StateObject private var viewModel = CharactersListViewModel()
    
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
                    case .loaded(let characters, _, let hasMore, let isLoadingMore):
                        charactersList(characters: characters, hasMore: hasMore, isLoadingMore: isLoadingMore)
                    case .error(let message):
                        Text(message)
                            .foregroundColor(.red)
                    }
                }
            }
            .onDisappear {
                viewModel.onDissapear()
            }
            .task {
                viewModel.starLoading()
            }
        }
    }
    
    @ViewBuilder
    private func charactersList(characters: [Character], hasMore: Bool, isLoadingMore: Bool) -> some View {
        List {
            ForEach(characters) { character in
                CharacterRow(character: character)
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
        .animation(.default, value: characters)
        .overlay {
            if characters.isEmpty {
                VStack {
                    Spacer()
                    Text("No Results")
                    Image(systemName: "magnifyingglass")
                    Text("Try searching with a different term")
                    Spacer()
                }
            }
        }
    }
}

struct CharacterRow: View {
    let character: Character
    
    var body: some View {
        NavigationLink(destination: CharacterDetailView(characterId: character.id)) {
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.headline)
                HStack {
                    Text("ID: \(character.id)")
                        .font(.title)
                    Spacer()
                    Text("Created at \(character.created, format: .dateTime.day().month().year())")
                        .font(.footnote)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    CharactersListView()
}
