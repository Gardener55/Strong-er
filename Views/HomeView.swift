//
//  HomeView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingAIWorkout = false
    @State private var showingSettings = false
    @State private var showingActiveWorkout = false
    @State private var showingWorkoutStats = false
    @State private var showingThisWeekHistory = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Workout Card
                    MotivationalMessageView()

                    if let currentWorkout = workoutManager.currentWorkout {
                        Button(action: { showingActiveWorkout = true }) {
                            CurrentWorkoutCard(workout: currentWorkout)
                        }
                        .buttonStyle(HapticButtonStyle())
                    }
                    
                    // Quick Actions
                    QuickActionsView(showingAIWorkout: $showingAIWorkout, showingActiveWorkout: $showingActiveWorkout)
                    
                    // Workout Stats
                    WorkoutStatsView(showingWorkoutStats: $showingWorkoutStats, showingThisWeekHistory: $showingThisWeekHistory)
                    
                    // Recent Workouts
                    RecentWorkoutsView()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Fitness Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(HapticButtonStyle())
                }
            }
            .sheet(isPresented: $showingAIWorkout) {
                AIWorkoutView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingActiveWorkout) {
                if let workout = workoutManager.currentWorkout {
                    ActiveWorkoutView(workout: Binding(
                        get: { workoutManager.currentWorkout ?? workout },
                        set: { newWorkout in workoutManager.currentWorkout = newWorkout }
                    ))
                    .environmentObject(workoutManager)
                }
            }
            .sheet(isPresented: $showingWorkoutStats) {
                WorkoutStatisticsView()
            }
            .sheet(isPresented: $showingThisWeekHistory) {
                ThisWeekHistoryView()
            }
        }
    }
}

struct CurrentWorkoutCard: View {
    let workout: Workout
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current Workout")
                    .font(.headline)
                Spacer()
                Button("Continue") {
                    // Navigate to workout
                }
                .buttonStyle(HapticButtonStyle())
            }
            
            Text(workout.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Text("\(workout.completedExercises)/\(workout.exercises.count) exercises")
                Spacer()
                Text(formatDuration(Date().timeIntervalSince(workout.date)))
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            ProgressView(value: Double(workout.completedExercises), total: Double(workout.exercises.count))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
}

struct QuickActionsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var showingAIWorkout: Bool
    @Binding var showingActiveWorkout: Bool
    @State private var showingCreateWorkout = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.bottom, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                Button(action: { showingAIWorkout = true }) {
                    QuickActionButton(
                        title: "AI Workout",
                        icon: "brain.head.profile",
                        color: Color("ActionPurple")
                    )
                }
                .buttonStyle(HapticButtonStyle())
                
                Button(action: { showingCreateWorkout = true }) {
                    QuickActionButton(
                        title: "Create Workout",
                        icon: "plus.circle",
                        color: Color("ActionBlue")
                    )
                }
                .buttonStyle(HapticButtonStyle())
                
                Button(action: {
                    workoutManager.startQuickWorkout()
                    showingActiveWorkout = true
                }) {
                    QuickActionButton(
                        title: "Quick Start",
                        icon: "play.circle",
                        color: Color("ActionGreen")
                    )
                }
                .buttonStyle(HapticButtonStyle())
                
                NavigationLink(destination: TemplatesView()) {
                    QuickActionButton(
                        title: "Templates",
                        icon: "folder",
                        color: Color("ActionOrange")
                    )
                }
                .buttonStyle(HapticButtonStyle())

                NavigationLink(destination: WorkoutHistoryView()) {
                    QuickActionButton(
                        title: "History",
                        icon: "calendar",
                        color: .red
                    )
                }
                .buttonStyle(HapticButtonStyle())

                NavigationLink(destination: ChartsView()) {
                    QuickActionButton(
                        title: "Charts",
                        icon: "chart.xyaxis.line",
                        color: .blue
                    )
                }
                .buttonStyle(HapticButtonStyle())
            }
        }
        .sheet(isPresented: $showingCreateWorkout) {
            CreateWorkoutView()
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct WorkoutStatsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var showingWorkoutStats: Bool
    @Binding var showingThisWeekHistory: Bool
    
    var body: some View {
        let stats = workoutManager.getWorkoutStats()
        
        VStack(alignment: .leading) {
            Text("Your Stats")
                .font(.headline)
                .padding(.bottom, 8)
            
            HStack(spacing: 20) {
                Button(action: { showingWorkoutStats = true }) {
                    StatCard(
                        title: "Total Workouts",
                        value: "\(stats.totalWorkouts)",
                        icon: "chart.bar.fill",
                        color: Color("ActionBlue")
                    )
                }
                .buttonStyle(HapticButtonStyle())
                
                Button(action: { showingThisWeekHistory = true }) {
                    StatCard(
                        title: "This Week",
                        value: "\(stats.thisWeekWorkouts)",
                        icon: "calendar",
                        color: Color("ActionGreen")
                    )
                }
                .buttonStyle(HapticButtonStyle())
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentWorkoutsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Recent Workouts")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    WorkoutHistoryView()
                }
                .font(.caption)
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                ForEach(workoutManager.workoutHistory.sorted { $0.date > $1.date }.prefix(3)) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        RecentWorkoutRow(workout: workout)
                    }
                    .buttonStyle(HapticButtonStyle())
                }
            }
        }
    }
}

struct RecentWorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(workout.exercises.count) exercises")
                    .font(.caption)
                
                if let duration = workout.duration {
                    Text(formatDuration(duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}

struct MotivationalMessageView: View {
    private let messageService = MotivationalMessageService()
    @State private var message: String = ""

    var body: some View {
        Text(message)
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .onAppear {
                message = messageService.getDailyMessage()
            }
    }
}