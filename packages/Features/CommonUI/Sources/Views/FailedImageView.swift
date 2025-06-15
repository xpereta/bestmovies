import SwiftUI

public struct FailedImageView: View {
    private let systemName: String

    public init(systemName: String = "film") {
        self.systemName = systemName
    }

    public var body: some View {
        Image(systemName: systemName)
            .resizable()
            .foregroundStyle(.gray)
            .opacity(0.6)
    }
}
