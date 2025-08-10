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
    @State private var restTimerEnabled = true
    @State private var defaultRestTime: TimeInterval = 60

    var body: some View {
        NavigationView {
            VStack {
                Text(workout.name)
                    .font(.largeTitle)
                    .padding()

                if restTimeRemaining > 0 && restTimerEnabled {
                    Text("Rest: \(Int(restTimeRemaining))s")
                        .font(.largeTitle)
                        .padding()
                }

                List {
                    Section(header: Text("Settings")) {
                        Toggle("Enable Rest Timer", isOn: $restTimerEnabled)
                        HStack {
                            Text("Default Rest Time")
                            TextField("Seconds", value: $defaultRestTime, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }

                    ForEach($workout.exercises) { $exercise in
                        Section(header: Text(exercise.exercise.name), footer: Button("Add Set") {
                            exercise.sets.append(WorkoutSet(restTime: defaultRestTime))
                        }) {
                            ForEach($exercise.sets) { $set in
                                let previousSet = workoutManager.getPreviousSet(for: exercise.exercise)
                                SetCompletionRow(set: $set, previousSet: previousSet) {
                                    if set.completed {
                                        startRestTimer(duration: set.restTime)
                                    } else {
                                        timer?.invalidate()
                                        restTimeRemaining = 0
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                exercise.sets.remove(atOffsets: indexSet)
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
        if !restTimerEnabled { return }
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
    let previousSet: WorkoutSet?
    var onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if let previous = previousSet {
                Text("Previous: \(previous.reps) reps at \(String(format: "%.1f", previous.weight ?? 0))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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

                TextField("Reps", value: $set.reps, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)

                if set.weight != nil {
                    TextField("Weight", value: $set.weight, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
        }
    }
}
