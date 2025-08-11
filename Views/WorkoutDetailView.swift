//
//  WorkoutDetailView.swift
//  Strong-er
//
//  Created by Jules on 8/11/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(workout.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let duration = workout.duration {
                    Text("Duration: \(formatDuration(duration))")
                        .font(.headline)
                }

                Text("Date: \(workout.date, style: .date)")
                    .font(.headline)

                ForEach(workout.exercises) { exercise in
                    VStack(alignment: .leading) {
                        Text(exercise.exercise.name)
                            .font(.title2)
                            .fontWeight(.semibold)

                        ForEach(exercise.sets) { set in
                            HStack {
                                Text("Set \(set.reps) reps")
                                if let weight = set.weight {
                                    Text("@ \(weight, specifier: "%.1f") lbs")
                                }
                            }
                            .font(.body)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Workout Details")
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: duration) ?? "N/A"
    }
}
