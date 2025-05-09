import SwiftUI
import Combine

struct SimpleCharactersListView: View {
    @StateObject private var viewModel = SimpleCharactersListViewModel()
    
    var body: some View {
        NavigationView {
            List() {
                ForEach(viewModel.characters) { character in
                    //                HStack {
                    //                    Text(character.name)
                    //                    Spacer()
                    //                    Text("\(character.id)")
                    //                }
                    CharacterRow(character: character)
                }
                if viewModel.hasMorePages {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear() {
                        viewModel.loadNextPage()
                    }
                }
            }
            .onAppear() {
                viewModel.starLoading()
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
    SimpleCharactersListView()
}
