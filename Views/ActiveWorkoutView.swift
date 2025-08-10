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
    @EnvironmentObject var userProfileService: UserProfileService
    @Environment(\.dismiss) private var dismiss

    // Timer states
    @State private var workoutTimer: Timer?
    @State private var workoutDuration: TimeInterval = 0
    @State private var isTimerRunning = false

    // Rest timer states
    @State private var restTimer: Timer?
    @State private var restTimeRemaining: TimeInterval = 0
    @State private var activeRestSetID: UUID?

    enum ActiveSheet: Identifiable {
        case datePicker, exercisePicker, restTimeEditor

        var id: Int {
            hashValue
        }
    }

    // View State
    @State private var workoutStartDate: Date
    @State private var setForRestTimeEdit: Binding<WorkoutSet>?
    @State private var activeSheet: ActiveSheet?

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
                headerView
                exerciseListView
                finishButtonView
            }
            .navigationTitle("Active Workout")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: startWorkoutTimer)
            .onDisappear(perform: stopWorkoutTimer)
            .sheet(item: $activeSheet) { sheet in
                sheetView(for: sheet)
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
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
                        activeSheet = .datePicker
                    }
                Text("Duration")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    private var exerciseListView: some View {
        List {
            ForEach($workout.exercises) { $exercise in
                ExerciseSectionView(
                    exercise: $exercise,
                    activeRestSetID: $activeRestSetID,
                    restTimeRemaining: $restTimeRemaining,
                    setForRestTimeEdit: $setForRestTimeEdit,
                    activeSheet: $activeSheet,
                    startRestTimer: startRestTimer,
                    stopRestTimer: stopRestTimer
                )
            }
            .onDelete(perform: removeExercise)

            addExerciseButtonSection
        }
    }

    private var addExerciseButtonSection: some View {
        Section {
            Button(action: {
                activeSheet = .exercisePicker
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Exercise")
                }
            }
        }
    }

    private var finishButtonView: some View {
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

    @ViewBuilder
    private func sheetView(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .datePicker:
            datePickerSheet
        case .exercisePicker:
            ExercisePickerView { exercise in
                let newExercise = WorkoutExercise(exercise: exercise)
                workout.exercises.append(newExercise)
                activeSheet = nil
            }
        case .restTimeEditor:
            if let setBinding = setForRestTimeEdit {
                RestTimeEditorView(set: setBinding)
                    .onDisappear {
                        if activeRestSetID == setBinding.wrappedValue.id {
                            restTimeRemaining = setBinding.wrappedValue.restTime
                        }
                        setForRestTimeEdit = nil
                    }
            }
        }
    }

    private var datePickerSheet: some View {
        VStack {
            DatePicker(
                "Workout Start Time",
                selection: $workoutStartDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()

            Button("Done") {
                if workoutStartDate > Date() {
                    workoutStartDate = Date()
                }
                activeSheet = nil
                recalculateDuration()
            }
            .padding()
        }
    }

    // MARK: - Timer Functions

    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }

    private func startWorkoutTimer() {
        if !isTimerRunning {
            workout.date = workoutStartDate
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
        if isTimerRunning {
            stopWorkoutTimer()
            startWorkoutTimer()
        }
    }

    private func startRestTimer(for set: WorkoutSet) {
        stopRestTimer()
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

    // MARK: - Data Functions

    private func finishWorkout() {
        stopWorkoutTimer()
        workout.duration = workoutDuration
        workoutManager.completeWorkout()
        dismiss()
    }

    private func removeExercise(at offsets: IndexSet) {
        workout.exercises.remove(atOffsets: offsets)
    }
}

// MARK: - Sub-Views

private struct ExerciseSectionView: View {
    @Binding var exercise: WorkoutExercise
    @Binding var activeRestSetID: UUID?
    @Binding var restTimeRemaining: TimeInterval
    @Binding var setForRestTimeEdit: Binding<WorkoutSet>?
    @Binding var activeSheet: ActiveWorkoutView.ActiveSheet?

    var startRestTimer: (WorkoutSet) -> Void
    var stopRestTimer: () -> Void

    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService

    var body: some View {
        Section(header: Text(exercise.exercise.name).font(.headline)) {
            ForEach(0..<exercise.sets.count, id: \.self) { index in
                ActiveWorkoutSetRow(
                    set: $exercise.sets[index],
                    setNumber: index + 1,
                    previousSet: workoutManager.getPreviousSet(for: exercise.exercise, setIndex: index),
                    weightUnit: userProfileService.userProfile.weightUnit,
                    onToggleCompletion: {
                        if exercise.sets[index].completed {
                            startRestTimer(exercise.sets[index])
                        } else {
                            stopRestTimer()
                        }
                    },
                    onEditRestTime: {
                        setForRestTimeEdit = $exercise.sets[index]
                        activeSheet = .restTimeEditor
                    },
                    isResting: activeRestSetID == exercise.sets[index].id,
                    restTimeRemaining: restTimeRemaining
                )
            }
            .onDelete { indexSet in
                var tempExercise = exercise
                tempExercise.sets.remove(atOffsets: indexSet)
                exercise = tempExercise
            }

            Button(action: {
                var tempExercise = exercise
                tempExercise.sets.append(WorkoutSet())
                exercise = tempExercise
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

private struct ActiveWorkoutSetRow: View {
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case reps, weight
    }

    @Binding var set: WorkoutSet
    let setNumber: Int
    let previousSet: WorkoutSet?
    let weightUnit: UserProfile.WeightUnit
    var onToggleCompletion: () -> Void
    var onEditRestTime: () -> Void
    let isResting: Bool
    let restTimeRemaining: TimeInterval

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Set \(setNumber)")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                if let previous = previousSet {
                    Text(previousSetText(for: previous))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 16) {
                Button(action: {
                    set.completed.toggle()
                    onToggleCompletion()
                }) {
                    Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(set.completed ? .green : .gray)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())

                VStack {
                    Text("Weight").font(.caption)
                    TextField("0", value: $set.weight, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .focused($focusedField, equals: .weight)
                }

                VStack {
                    Text("Reps").font(.caption)
                    TextField("0", value: $set.reps, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .focused($focusedField, equals: .reps)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }

            if isResting {
                Button(action: onEditRestTime) {
                    HStack {
                        Spacer()
                        Image(systemName: "timer")
                        Text(timeString(from: restTimeRemaining))
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
    }

    private func previousSetText(for set: WorkoutSet) -> String {
        let weight = set.weight ?? 0
        var displayText = "Prev: \(set.reps) x "

        if weightUnit == .pounds {
            let weightInLbs = weight * 2.20462
            displayText += "\(String(format: "%.1f", weightInLbs)) lbs"
        } else {
            displayText += "\(String(format: "%.1f", weight)) kg"
        }

        return displayText
    }

    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

private struct RestTimeEditorView: View {
    @Binding var set: WorkoutSet
    @Environment(\.dismiss) private var dismiss
    @State private var newRestTime: String

    init(set: Binding<WorkoutSet>) {
        _set = set
        _newRestTime = State(initialValue: String(Int(set.wrappedValue.restTime)))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Update rest time for this set.")
                    .font(.headline)

                TextField("Seconds", text: $newRestTime)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)

                Button("Save") {
                    if let time = TimeInterval(newRestTime) {
                        set.restTime = time
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Edit Rest Time")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}
