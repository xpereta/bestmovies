import SwiftUI
import Combine

struct CharactersListView: View {
    @StateObject private var viewModel = CharactersListViewModel()
    
    var body: some View {
        List(viewModel.characters) { character in
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.headline)
                Text(character.created.description)
            }
        }
        .task {
            viewModel.loadCharacters()
        }
    }
}

#Preview {
    CharactersListView()
}
