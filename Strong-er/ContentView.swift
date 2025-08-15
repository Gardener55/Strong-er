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
    @EnvironmentObject var userProfileService: UserProfileService
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var exerciseDatabase = ExerciseDatabase.shared
    @State private var selectedTab = 0

    // Enum to manage presentation states
    enum ActiveSheet: Identifiable {
        case gettingStarted, activeWorkout

        var id: Int {
            hashValue
        }
    }

    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            WorkoutHistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("History")
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
        .environmentObject(userProfileService)
        .environment(\.managedObjectContext, viewContext)
        .onAppear {
            if !userProfileService.userProfile.isProfileSetupComplete {
                activeSheet = .gettingStarted
            }
        }
        .onChange(of: userProfileService.userProfile.isProfileSetupComplete) { isComplete in
            if !isComplete {
                activeSheet = .gettingStarted
            } else if activeSheet == .gettingStarted {
                activeSheet = nil
            }
        }
        .onChange(of: workoutManager.currentWorkout) { workout in
            if workout != nil {
                activeSheet = .activeWorkout
            } else if activeSheet == .activeWorkout {
                activeSheet = nil
            }
        }
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .gettingStarted:
                GettingStartedView()
                    .environmentObject(userProfileService)
            case .activeWorkout:
                if let workout = workoutManager.currentWorkout {
                    ActiveWorkoutView(workout: Binding(
                        get: { workoutManager.currentWorkout ?? workout },
                        set: { newWorkout in workoutManager.currentWorkout = newWorkout }
                    ))
                    .environmentObject(workoutManager)
                    .environmentObject(userProfileService)
                    .environmentObject(exerciseDatabase)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(UserProfileService.shared)
        .environmentObject(WorkoutManager())
        .environmentObject(ExerciseDatabase.shared)
}
