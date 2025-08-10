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
                ForEach(workoutManager.workoutHistory) { workout in
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
                }
            }
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView()
            }
        }
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            let workout = workoutManager.workoutHistory[index]
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

struct WorkoutDetailView: View {
    let workout: Workout
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    
    private var totalVolume: Double {
        workout.exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                setTotal + ((set.weight ?? 0) * Double(set.reps))
            }
        }
    }

    private var formattedTotalVolume: String {
        let unit = userProfileService.userProfile.weightUnit
        let volume: Double
        let unitString: String

        switch unit {
        case .kilograms:
            volume = totalVolume
            unitString = "kg"
        case .pounds:
            volume = totalVolume * 2.20462
            unitString = "lbs"
        }
        return String(format: "%.1f %@", volume, unitString)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Workout Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    HStack {
                        Text(workout.date, style: .date)
                        Spacer()
                        Text("Total Volume: \(formattedTotalVolume)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    if let duration = workout.duration {
                        Text("Duration: \(formatDuration(duration))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Exercises
                LazyVStack(spacing: 12) {
                    ForEach(workout.exercises) { exercise in
                        WorkoutExerciseDetailView(workoutExercise: exercise)
                            .environmentObject(userProfileService)
                    }
                }
                
                // Notes
                if !workout.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(workout.notes)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Repeat") {
                    workoutManager.startWorkout(workout)
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: duration) ?? ""
    }
}

struct WorkoutExerciseDetailView: View {
    let workoutExercise: WorkoutExercise
    @EnvironmentObject var userProfileService: UserProfileService

    private func weightString(for set: WorkoutSet) -> String {
        guard let weight = set.weight, weight > 0 else { return "" }

        let unit = userProfileService.userProfile.weightUnit
        let convertedWeight: Double
        let unitString: String

        switch unit {
        case .kilograms:
            convertedWeight = weight
            unitString = "kg"
        case .pounds:
            convertedWeight = weight * 2.20462
            unitString = "lbs"
        }

        return String(format: "@ %.1f %@", convertedWeight, unitString)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workoutExercise.exercise.name)
                .font(.headline)
            
            ForEach(Array(workoutExercise.sets.enumerated()), id: \.offset) { index, set in
                HStack {
                    Text("Set \(index + 1):")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(set.reps) reps")
                        .font(.caption)
                    
                    Text(weightString(for: set))
                        .font(.caption)
                    
                    Spacer()
                    
                    if set.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            
            if !workoutExercise.notes.isEmpty {
                Text(workoutExercise.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}