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

    // Timer states
    @State private var workoutTimer: Timer?
    @State private var workoutDuration: TimeInterval = 0
    @State private var isTimerRunning = false

    // Rest timer states
    @State private var restTimer: Timer?
    @State private var restTimeRemaining: TimeInterval = 0
    @State private var activeRestSetID: UUID?

    // Editable start time
    @State private var showingDatePicker = false
    @State private var workoutStartDate: Date

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    init(workout: Binding<Workout>) {
        _workout = workout
        _workoutStartDate = State(initialValue: workout.wrappedValue.date)
    }

    var body: some View {
        NavigationView {
            VStack {
                // Workout header
                HStack {
                    VStack(alignment: .leading) {
                        Text(workout.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(dateFormatter.string(from: workoutStartDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(timeString(from: workoutDuration))
                            .font(.title)
                            .fontWeight(.semibold)
                            .onTapGesture {
                                showingDatePicker = true
                            }
                        Text("Duration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                List {
                    ForEach($workout.exercises) { $exercise in
                        Section(header: Text(exercise.exercise.name).font(.headline)) {
                            ForEach(Array($exercise.sets.enumerated()), id: \.element.id) { index, $set in
                                SetRow(
                                    set: $set,
                                    setNumber: index + 1,
                                    previousSet: workoutManager.getPreviousSet(for: exercise.exercise, setIndex: index),
                                    onToggleCompletion: {
                                        if $set.completed.wrappedValue {
                                            startRestTimer(for: $set.wrappedValue)
                                        } else {
                                            stopRestTimer()
                                        }
                                    },
                                    isResting: activeRestSetID == set.id,
                                    restTimeRemaining: restTimeRemaining
                                )
                            }
                            .onDelete { indexSet in
                                exercise.sets.remove(atOffsets: indexSet)
                            }

                            Button(action: {
                                exercise.sets.append(WorkoutSet())
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Set")
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }

                Button(action: {
                    finishWorkout()
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
            .onAppear(perform: startWorkoutTimer)
            .onDisappear(perform: stopWorkoutTimer)
            .sheet(isPresented: $showingDatePicker) {
                VStack {
                    DatePicker(
                        "Workout Start Time",
                        selection: $workoutStartDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()

                    Button("Done") {
                        showingDatePicker = false
                        recalculateDuration()
                    }
                    .padding()
                }
            }
        }
    }

    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }

    private func startWorkoutTimer() {
        if !isTimerRunning {
            workout.date = workoutStartDate // Update workout date
            workoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                workoutDuration = Date().timeIntervalSince(workoutStartDate)
            }
            isTimerRunning = true
        }
    }

    private func stopWorkoutTimer() {
        workoutTimer?.invalidate()
        isTimerRunning = false
    }

    private func recalculateDuration() {
        workoutDuration = Date().timeIntervalSince(workoutStartDate)
        // If timer is running, restart it to ensure it's in sync
        if isTimerRunning {
            stopWorkoutTimer()
            startWorkoutTimer()
        }
    }

    private func startRestTimer(for set: WorkoutSet) {
        stopRestTimer() // Stop any existing timer
        restTimeRemaining = set.restTime
        activeRestSetID = set.id
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if restTimeRemaining > 0 {
                restTimeRemaining -= 1
            } else {
                stopRestTimer()
            }
        }
    }

    private func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        activeRestSetID = nil
        restTimeRemaining = 0
    }

    private func finishWorkout() {
        stopWorkoutTimer()
        workout.duration = workoutDuration
        workoutManager.completeWorkout()
        dismiss()
    }
}

private struct SetRow: View {
    @Binding var set: WorkoutSet
    let setNumber: Int
    let previousSet: WorkoutSet?
    var onToggleCompletion: () -> Void
    let isResting: Bool
    let restTimeRemaining: TimeInterval

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Set Number
                Text("Set \(setNumber)")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                // Previous Set Info
                if let previous = previousSet {
                    Text("Prev: \(previous.reps) x \(String(format: "%.1f", previous.weight ?? 0)) lbs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 16) {
                // Completion Checkmark
                Button(action: {
                    set.completed.toggle()
                    onToggleCompletion()
                }) {
                    Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(set.completed ? .green : .gray)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())

                // Weight Input
                VStack {
                    Text("Weight")
                        .font(.caption)
                    TextField("0", value: $set.weight, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                }

                // Reps Input
                VStack {
                    Text("Reps")
                        .font(.caption)
                    TextField("0", value: $set.reps, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
            }

            // Rest Timer
            if isResting {
                HStack {
                    Spacer()
                    Image(systemName: "timer")
                    Text(timeString(from: restTimeRemaining))
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
    }

    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
