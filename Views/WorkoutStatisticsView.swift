//
//  WorkoutStatisticsView.swift
//  Strong-er
//
//  Created by Jules on 8/11/25.
//

import SwiftUI

struct WorkoutStatisticsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    let stats = workoutManager.getWorkoutStats()

                    Text("Workout Statistics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

                    StatRow(title: "Total Workouts", value: "\(stats.totalWorkouts)")
                    StatRow(title: "Total Time Spent", value: formatDuration(stats.totalDuration))
                    StatRow(title: "Average Workouts Per Week", value: String(format: "%.1f", stats.averageWorkoutsPerWeek))
                    StatRow(title: "Average Time Per Workout", value: formatDuration(stats.averageDuration))

                    if let mostCompleted = stats.mostCompletedExercise {
                        StatRow(title: "Most Completed Exercise", value: "\(mostCompleted.name) (\(mostCompleted.count) times)")
                    }

                    StatRow(title: "Most Exercises in One Workout", value: "\(stats.mostExercisesInOneWorkout)")
                    StatRow(title: "Most Reps in One Set", value: "\(stats.mostRepsInOneSet)")
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.buttonStyle(HapticButtonStyle()))
        }
    }

    @Environment(\.presentationMode) var presentationMode

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: duration) ?? "N/A"
    }
}

struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
