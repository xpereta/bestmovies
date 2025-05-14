import SwiftUI

@main
struct BestMoviesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CoordinatorView()
        }
    }
}
