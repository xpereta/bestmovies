import SwiftUI
import Combine

struct CharactersListView: View {
    @StateObject private var viewModel = CharactersListViewModel()
    
    var body: some View {
        List(viewModel.characters) { character in
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.headline)
                HStack {
                    Spacer()
                    Text("Created at \(character.created, format: .dateTime.day().month().year())")
                        .font(.footnote)
                }
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
