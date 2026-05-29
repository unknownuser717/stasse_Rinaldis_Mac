//
//  stasse_rinaldisApp.swift
//  stasse_rinaldis
//
//  Created by Damien Rinaldis on 29/05/2026.
//

import SwiftUI

@main
struct stasse_rinaldisApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
