import SwiftUI
import Combine

struct CharactersListView: View {
    @StateObject private var viewModel = CharactersListViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .initial:
                    Color.clear
                case .loading:
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded(let characters, _, let hasNext):
                    List {
                        ForEach(characters) { character in
                            CharacterRow(character: character)
                        }
                        
                        if hasNext {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden)
                                .onAppear {
                                    viewModel.send(.loadNextPage)
                                }
                        }
                    }
                    .listStyle(.plain)
                case .loadingNextPage(let characters):
                    List {
                        ForEach(characters) { character in
                            CharacterRow(character: character)
                        }
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                case .error(let message):
                    VStack {
                        Text("Error: \(message)")
                        Button("Retry") {
                            viewModel.send(.retry)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Characters")
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }
}

struct CharacterRow: View {
    let character: Character
    
    var body: some View {
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

#Preview {
    CharactersListView()
}
