//
//  SpaceTDApp.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//

import SwiftUI

@main
struct SpaceTDApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
