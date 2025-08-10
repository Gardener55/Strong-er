//
//  ContentView.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/8/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var exerciseDatabase = ExerciseDatabase.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Workouts")
                }
                .tag(1)
            
            ExerciseLibraryView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Exercises")
                }
                .tag(2)
            
            TemplatesView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Templates")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .environmentObject(workoutManager)
        .environmentObject(exerciseDatabase)
        .environment(\.managedObjectContext, viewContext)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
