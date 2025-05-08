import SwiftUI
import Combine

struct CharactersListView: View {
    @StateObject private var viewModel = CharactersListViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .initial:
                EmptyView()
            case .loading:
                ProgressView("Loading...")
            case .loaded(let characters):
                List(characters) { character in
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
            case .error(let message):
                VStack {
                    Text("Error: \(message)")
                    Button("Retry") {
                        viewModel.send(.retry)
                    }
                }
            }
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }
}

#Preview {
    CharactersListView()
}
