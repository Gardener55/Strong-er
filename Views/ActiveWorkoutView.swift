//
//  ActiveWorkoutView.swift
//  Strong-er
//
//  Created by Jules on 8/10/25.
//

import SwiftUI

struct ActiveWorkoutView: View {
    @Binding var workout: Workout
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    @State private var timer: Timer?
    @State private var restTimeRemaining: TimeInterval = 0

    var body: some View {
        NavigationView {
            VStack {
                Text(workout.name)
                    .font(.largeTitle)
                    .padding()

                if restTimeRemaining > 0 {
                    Text("Rest: \(Int(restTimeRemaining))s")
                        .font(.largeTitle)
                        .padding()
                }

                List {
                    ForEach($workout.exercises) { $exercise in
                        Section(header: Text(exercise.exercise.name)) {
                            ForEach($exercise.sets) { $set in
                                SetCompletionRow(set: $set) {
                                    if set.completed {
                                        startRestTimer(duration: set.restTime)
                                    } else {
                                        timer?.invalidate()
                                        restTimeRemaining = 0
                                    }
                                }
                            }
                        }
                    }
                }

                Button(action: {
                    workoutManager.completeWorkout()
                    dismiss()
                }) {
                    Text("Finish Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Active Workout")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                timer?.invalidate()
            }
        }
    }

    private func startRestTimer(duration: TimeInterval) {
        restTimeRemaining = duration
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if restTimeRemaining > 0 {
                restTimeRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

struct SetCompletionRow: View {
    @Binding var set: WorkoutSet
    var onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                set.completed.toggle()
                onToggle()
            }) {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.completed ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())

            if set.isWarmup {
                Text("Warmup")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .background(Color.yellow.opacity(0.5))
                    .cornerRadius(8)
            }

            Text("Reps: \(set.reps)")
            if let weight = set.weight {
                Text("Weight: \(weight, specifier: "%.1f")")
            }
        }
    }
}
