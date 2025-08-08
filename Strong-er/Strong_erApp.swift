//
//  Strong_erApp.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/8/25.
//

import SwiftUI

@main
struct Strong_erApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        }
    }
}
