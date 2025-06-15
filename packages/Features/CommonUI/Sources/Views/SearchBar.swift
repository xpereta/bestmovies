import SwiftUI

public struct SearchBar: View {
    @Binding var text: String

    public init(text: Binding<String>) {
        self._text = text
    }

    public var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search movies...", text: $text)
                .autocorrectionDisabled()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @State var text = ""
    VStack {
        SearchBar(text: $text)
        Spacer()
    }
}

@available(iOS 18.0, *)
#Preview("with text") {
    @Previewable @State var text = "Matrix"
    VStack {
        SearchBar(text: $text)
        Spacer()
    }
}
