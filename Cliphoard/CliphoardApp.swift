//
//  CliphoardApp.swift
//  Cliphoard
//
//  Created by Jason Qiu on 3/4/25.
//

import SwiftUI

@main
struct CliphoardApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
