import SwiftUI

struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel
    
    init(characterId: Int) {
        _viewModel = StateObject(wrappedValue: CharacterDetailViewModel(characterId: characterId))
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading character...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded(let character):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(character.name)
                            .font(.title)
                            .bold()
                        AsyncImage(
                            url: URL(string: character.image),
                            transaction: Transaction(
                                animation: .easeIn(duration: 0.2)
                            )
                        ){ phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .transition(.opacity)
                                
                            case .failure(_):
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .opacity(0.3)
                                
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray)
                                    .opacity(0.3)
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                            @unknown default:
                                ProgressView()
                            }
                        }
                        Text("Created: \(character.created.formatted(date: .long, time: .standard))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            case .error(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .foregroundColor(.red)
                    
                    Button("Try Again") {
                        viewModel.loadCharacter()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadCharacter()
        }
    }
}

#Preview {
    NavigationView {
        CharacterDetailView(characterId: 1)
    }
}
