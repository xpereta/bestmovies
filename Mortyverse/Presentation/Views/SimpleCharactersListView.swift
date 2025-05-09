import SwiftUI
import Combine

struct SimpleCharactersListView: View {
    @StateObject private var viewModel = SimpleCharactersListViewModel()
    
    var body: some View {
        List() {
            ForEach(viewModel.characters) { character in
                HStack {
                    Text(character.name)
                    Spacer()
                    Text("\(character.id)")
                }
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

#Preview {
    SimpleCharactersListView()
}
