import SwiftUI

struct FailedImageView: View {
    let systemName: String

    init(systemName: String = "film") {
        self.systemName = systemName
    }

    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .foregroundStyle(.gray)
            .opacity(0.6)
    }
}
