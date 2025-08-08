//
//  Strong_erApp.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/8/25.
//

import SwiftUI

enum ColorScheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

@main
struct Strong_erApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    @AppStorage("colorScheme") private var colorScheme: ColorScheme = .system

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(workoutManager)
                .preferredColorScheme(colorScheme == .dark ? .dark : colorScheme == .light ? .light : nil)
        }
    }
}
