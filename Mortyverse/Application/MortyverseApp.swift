//
//  MortyverseApp.swift
//  Mortyverse
//
//  Created by Xavier Pereta París on 6/5/25.
//

import SwiftUI

@main
struct MortyverseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            SimpleCharactersListView()
        }
    }
}
