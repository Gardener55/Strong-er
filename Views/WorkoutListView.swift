//
//  WorkoutListView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/WorkoutListView.swift
import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    @State private var showingCreateWorkout = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workoutManager.workoutHistory.sorted { $0.date > $1.date }) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutListRow(workout: workout)
                    }
                }
                .onDelete(perform: deleteWorkouts)
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateWorkout = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(HapticButtonStyle())
                }
            }
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView()
            }
        }
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        let sortedWorkouts = workoutManager.workoutHistory.sorted { $0.date > $1.date }
        for index in offsets {
            let workout = sortedWorkouts[index]
            workoutManager.deleteWorkout(workout)
        }
    }
}

struct WorkoutListRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.name)
                .font(.headline)
            
            Text(workout.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(workout.exercises.count) exercises")
                
                if let duration = workout.duration {
                    Text("• \(formatDuration(duration))")
                }
                
                Spacer()
                
                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}
