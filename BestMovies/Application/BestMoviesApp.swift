import FactoryKit
import Movies
import SwiftUI

@main
struct BestMoviesApp: App {
    var body: some Scene {
        WindowGroup {
            let dependencies = Container.shared.appMoviesDependencies.resolve()
            CoordinatorView(dependencies: dependencies)
        }
    }
}
