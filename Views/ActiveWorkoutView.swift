//
//  ActiveWorkoutView.swift
//  Strong-er
//
//  Created by Jules on 8/10/25.
//

import SwiftUI
import AVFoundation

private struct RestTimeEditorView: View {
    @Binding var set: WorkoutSet
    @Environment(\.dismiss) private var dismiss
    @State private var newRestTime: String

    init(set: Binding<WorkoutSet>) {
        _set = set
        _newRestTime = State(initialValue: String(Int(set.wrappedValue.restTime)))
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
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
                    triggerHapticFeedback()
                    if let time = TimeInterval(newRestTime) {
                        set.restTime = time
                    }
                    dismiss()
                }
                .buttonStyle(HapticButtonStyle())
            }
            .navigationTitle("Edit Rest Time")
            .navigationBarItems(trailing: Button("Cancel") { triggerHapticFeedback(); dismiss() }.buttonStyle(HapticButtonStyle()))
        }
    }
}

private struct ExerciseRestTimeEditorView: View {
    @Binding var exercise: WorkoutExercise
    @Environment(\.dismiss) private var dismiss
    @State private var newRestTime: String

    init(exercise: Binding<WorkoutExercise>) {
        _exercise = exercise
        _newRestTime = State(initialValue: String(Int(exercise.wrappedValue.restTime ?? 60)))
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Update rest time for all sets in this exercise.")
                    .font(.headline)

                TextField("Seconds", text: $newRestTime)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)

                Button("Save") {
                    triggerHapticFeedback()
                    if let time = TimeInterval(newRestTime) {
                        exercise.restTime = time
                        // Also update all existing sets for this exercise
                        for i in 0..<exercise.sets.count {
                            exercise.sets[i].restTime = time
                        }
                    }
                    dismiss()
                }
                .buttonStyle(HapticButtonStyle())
            }
            .navigationTitle("Edit Exercise Rest Time")
            .navigationBarItems(trailing: Button("Cancel") { triggerHapticFeedback(); dismiss() }.buttonStyle(HapticButtonStyle()))
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
    var onDelete: () -> Void

    @EnvironmentObject var restTimerViewModel: RestTimerViewModel
    @State private var weightInput: String = ""

    private var repsProxy: Binding<String> {
        Binding<String>(
            get: {
                set.reps == 0 ? "" : "\(set.reps)"
            },
            set: {
                if let value = Int($0) {
                    set.reps = value
                } else if $0.isEmpty {
                    set.reps = 0
                }
            }
        )
    }


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
                    withAnimation {
                        set.completed.toggle()
                        onToggleCompletion()
                    }
                }) {
                    Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(set.completed ? .green : .gray)
                        .font(.title2)
                }
                .buttonStyle(HapticButtonStyle())

                VStack {
                    Text("Weight (\(weightUnit.rawValue))").font(.caption)
                    TextField("0", text: $weightInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .focused($focusedField, equals: .weight)
                        .onAppear {
                            updateWeightInput()
                        }
                        .onChange(of: weightInput) { handleWeightChange() }
                        .onChange(of: set.weight) { updateWeightInput(fromModel: true) }

                }

                VStack {
                    Text("Reps").font(.caption)
                    TextField("0", text: repsProxy)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .focused($focusedField, equals: .reps)
                }
            }

            if restTimerViewModel.activeRestSetID == set.id {
                VStack(spacing: 4) {
                    ProgressView(value: set.restTime - restTimerViewModel.restTimeRemaining, total: set.restTime)
                        .progressViewStyle(LinearProgressViewStyle())
                        .animation(.linear, value: restTimerViewModel.restTimeRemaining)

                    Button(action: onEditRestTime) {
                        HStack {
                            Image(systemName: "timer")
                            Text(timeString(from: restTimerViewModel.restTimeRemaining))
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(HapticButtonStyle())
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
        .swipeActions {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func formatWeight(_ weight: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2 // Adjust as needed
        return formatter.string(from: NSNumber(value: weight)) ?? "\(weight)"
    }

    private func updateWeightInput(fromModel: Bool = false) {
        // This function is called when the view appears or when the model value changes.
        // It formats the weight from the model (which is always in kg) to the correct display unit.
        guard let weight = set.weight else {
            weightInput = ""
            return
        }

        let displayWeight = weightUnit == .pounds ? weight * 2.20462 : weight

        // To prevent infinite loops, we check if the new value is different before updating.
        let newWeightString = formatWeight(displayWeight)

        if let currentInputWeight = Double(weightInput) {
             let currentStoredWeight = weightUnit == .pounds ? currentInputWeight / 2.20462 : currentInputWeight
             if abs(currentStoredWeight - weight) < 0.01 {
                 return
             }
        }

        weightInput = newWeightString
    }

    private func handleWeightChange() {
        // This function is called whenever the user types in the weight field.
        // It validates the input and updates the model (in kg).
        var filtered = weightInput.filter { "0123456789.".contains($0) }

        if let dotIndex = filtered.firstIndex(of: ".") {
            let components = filtered.split(separator: ".")
            if components.count > 1 {
                let decimalPart = components[1]
                if decimalPart.count > 2 {
                    let truncatedDecimal = decimalPart.prefix(2)
                    filtered = "\(components[0]).\(truncatedDecimal)"
                }
            }
            if components.count > 2 {
                 let firstPart = components[0]
                 let secondPart = components[1]
                 filtered = "\(firstPart).\(secondPart)"
            }
        }

        if filtered != weightInput {
            weightInput = filtered
        }

        if let value = Double(filtered) {
            let storedWeight = weightUnit == .pounds ? value / 2.20462 : value
            if abs((set.weight ?? 0) - storedWeight) > 0.001 {
                set.weight = storedWeight
            }
        } else {
            set.weight = nil
        }
    }

    private func previousSetText(for set: WorkoutSet) -> String {
        let weight = set.weight ?? 0
        var displayText = "Prev: \(set.reps) x "

        if weightUnit == .pounds {
            let weightInLbs = weight * 2.20462
            displayText += "\(formatWeight(weightInLbs)) lbs"
        } else {
            displayText += "\(formatWeight(weight)) kg"
        }

        return displayText
    }

    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

private struct ExerciseSectionView: View {
    @Binding var exercise: WorkoutExercise
    @Binding var setForRestTimeEdit: Binding<WorkoutSet>?
    @Binding var exerciseForRestTimeEdit: Binding<WorkoutExercise>?
    @Binding var exerciseToReplace: Binding<WorkoutExercise>?
    @Binding var activeSheet: ActiveWorkoutView.ActiveSheet?

    var onDelete: () -> Void
    var triggerHapticFeedback: () -> Void

    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    @EnvironmentObject var restTimerViewModel: RestTimerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(exercise.exercise.name)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGroupedBackground))
                .swipeActions {
                    Button(role: .destructive) {
                        triggerHapticFeedback()
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        triggerHapticFeedback()
                        exerciseForRestTimeEdit = $exercise
                        activeSheet = .exerciseRestTimeEditor
                    } label: {
                        Label("Edit Rest", systemImage: "timer")
                    }
                    .tint(.blue)
                    Button {
                        triggerHapticFeedback()
                        exerciseToReplace = $exercise
                        activeSheet = .exercisePicker
                    } label: {
                        Label("Replace", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .tint(.orange)
                }

            ForEach($exercise.sets) { $set in
                if let index = exercise.sets.firstIndex(where: { $0.id == $set.id }) {
                    ActiveWorkoutSetRow(
                        set: $set,
                        setNumber: index + 1,
                        previousSet: workoutManager.getPreviousSet(for: exercise.exercise, setIndex: index),
                        weightUnit: userProfileService.userProfile.weightUnit,
                        onToggleCompletion: {
                            triggerHapticFeedback()
                            if $set.wrappedValue.completed {
                                restTimerViewModel.startTimer(for: $set.wrappedValue)
                                // Autopopulate next set
                                let currentSet = $set.wrappedValue
                                let nextSetIndex = index + 1
                                if nextSetIndex < exercise.sets.count {
                                    exercise.sets[nextSetIndex].weight = currentSet.weight
                                    exercise.sets[nextSetIndex].reps = currentSet.reps
                                }
                            } else {
                                restTimerViewModel.stopTimer()
                            }
                        },
                        onEditRestTime: {
                            triggerHapticFeedback()
                            setForRestTimeEdit = $set
                            activeSheet = .restTimeEditor
                        },
                        onDelete: {
                            triggerHapticFeedback()
                            exercise.sets.removeAll { $0.id == $set.id }
                        }
                    )
                    .padding(.horizontal)
                }
            }

            Button(action: {
                triggerHapticFeedback()
                withAnimation {
                    let newSetRestTime = exercise.restTime ?? userProfileService.userProfile.defaultRestTimer
                    exercise.sets.append(WorkoutSet(restTime: newSetRestTime))
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Set")
                }
                .padding()
            }
            .buttonStyle(HapticButtonStyle())
        }
        .listRowInsets(EdgeInsets())
    }

    private func deleteSet(at offsets: IndexSet) {
        exercise.sets.remove(atOffsets: offsets)
    }
}

struct ActiveWorkoutView: View {
    @Binding var workout: Workout
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    @EnvironmentObject var exerciseDatabase: ExerciseDatabase
    @Environment(\.dismiss) private var dismiss

    @StateObject private var restTimerViewModel = RestTimerViewModel()

    // Rest timer states

    enum ActiveSheet: Identifiable {
        case datePicker, exercisePicker, restTimeEditor, exerciseRestTimeEditor

        var id: Int {
            hashValue
        }
    }

    // View State
    @State private var workoutStartDate: Date
    @State private var setForRestTimeEdit: Binding<WorkoutSet>?
    @State private var exerciseForRestTimeEdit: Binding<WorkoutExercise>?
    @State private var activeSheet: ActiveSheet?
    @State private var showingAlert = false
    @State private var alertInfo: AlertInfo?


    // For summary view navigation
    @State private var showSummary = false
    @State private var workoutToSummarize: Workout?
    @State private var summaryData: (brokenPRs: [PersonalRecord], newAchievements: [Achievement])?

    // For replacing an exercise
    @State private var exerciseToReplace: Binding<WorkoutExercise>?

    private struct AlertInfo {
        let title: String
        let message: String
        let primaryButton: Alert.Button
        let secondaryButton: Alert.Button?
    }

    private var hasUnfinishedSets: Bool {
        workout.exercises.flatMap { $0.sets }.contains { !$0.completed }
    }

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
                bottomButtonsView
            }
            .navigationTitle("Active Workout")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: initializeWorkout)
            .sheet(item: $activeSheet) { sheet in
                sheetView(for: sheet)
            }
            .sheet(isPresented: $showSummary) {
                PostWorkoutSummaryView(
                    workout: workoutToSummarize ?? workout,
                    summaryData: summaryData ?? ([], []),
                    dismissAction: {
                        self.showSummary = false
                        // This will dismiss the ActiveWorkoutView
                        self.dismiss()
                    }
                )
            }
            .onTapGesture {
                hideKeyboard()
            }
            .alert(isPresented: $showingAlert) {
                let primaryButton = alertInfo?.primaryButton ?? .default(Text("OK"))
                let secondaryButton = alertInfo?.secondaryButton

                if let secondaryButton = secondaryButton {
                    return Alert(title: Text(alertInfo?.title ?? ""), message: Text(alertInfo?.message ?? ""), primaryButton: primaryButton, secondaryButton: secondaryButton)
                } else {
                    return Alert(title: Text(alertInfo?.title ?? ""), message: Text(alertInfo?.message ?? ""), dismissButton: primaryButton)
                }
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
                WorkoutTimerView(startDate: workoutStartDate)
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
                    setForRestTimeEdit: $setForRestTimeEdit,
                    exerciseForRestTimeEdit: $exerciseForRestTimeEdit,
                    exerciseToReplace: $exerciseToReplace,
                    activeSheet: $activeSheet,
                    onDelete: {
                        if let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
                            workout.exercises.remove(at: index)
                        }
                    },
                    triggerHapticFeedback: triggerHapticFeedback
                )
            }

            addExerciseButtonSection
        }
        .environmentObject(restTimerViewModel)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: doneButtonAction)
                    .buttonStyle(HapticButtonStyle())
            }
        }
    }

    private var addExerciseButtonSection: some View {
        Section {
            Button(action: addExercise) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Exercise")
                }
            }
            .buttonStyle(HapticButtonStyle())
        }
    }

    private var bottomButtonsView: some View {
        HStack(spacing: 16) {
            Button(action: cancelWorkoutAction) {
                Text("Cancel Workout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .buttonStyle(HapticButtonStyle())

            Button(action: finishWorkoutAction) {
                Text("Finish Workout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .buttonStyle(HapticButtonStyle())
        }
        .padding()
    }

    @ViewBuilder
    private func sheetView(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .datePicker:
            datePickerSheet
        case .exercisePicker:
            ExercisePickerView { selectedExercise in
                withAnimation {
                    if let exerciseToReplaceBinding = exerciseToReplace {
                        if let index = workout.exercises.firstIndex(where: { $0.id == exerciseToReplaceBinding.wrappedValue.id }) {
                            let newExercise = WorkoutExercise(exercise: selectedExercise)
                            workout.exercises[index] = newExercise
                        }
                        exerciseToReplace = nil
                    } else {
                        let defaultRest = userProfileService.userProfile.defaultRestTimer
                        var newExercise = WorkoutExercise(exercise: selectedExercise, restTime: defaultRest)
                        if !newExercise.sets.isEmpty {
                            newExercise.sets[0].restTime = defaultRest
                        }
                        workout.exercises.append(newExercise)
                    }
                }
                activeSheet = nil
            }
            .environmentObject(exerciseDatabase)
        case .restTimeEditor:
            if let setBinding = setForRestTimeEdit {
                RestTimeEditorView(set: setBinding)
                    .onDisappear {
                        if restTimerViewModel.activeRestSetID == setBinding.wrappedValue.id {
                            // If the timer is active for this set, restart it with the new time
                            restTimerViewModel.startTimer(for: setBinding.wrappedValue)
                        }
                        setForRestTimeEdit = nil
                    }
            }
        case .exerciseRestTimeEditor:
            if let exerciseBinding = exerciseForRestTimeEdit {
                ExerciseRestTimeEditorView(exercise: exerciseBinding)
                    .onDisappear {
                        exerciseForRestTimeEdit = nil
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
                workout.date = workoutStartDate
                activeSheet = nil
            }
            .buttonStyle(HapticButtonStyle())
            .padding()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Timer Functions

    private func initializeWorkout() {
        workout.date = workoutStartDate
    }

    private enum WorkoutCompletionType {
        case standard, autocomplete, discard
    }
    // MARK: - Data Functions

    private func finishWorkout(completionType: WorkoutCompletionType) {
        switch completionType {
        case .standard:
            // No changes needed, just finish the workout as is.
            break
        case .autocomplete:
            // Mark all unfinished sets as completed.
            for i in 0..<workout.exercises.count {
                for j in 0..<workout.exercises[i].sets.count {
                    if !workout.exercises[i].sets[j].completed {
                        workout.exercises[i].sets[j].completed = true
                    }
                }
            }
        case .discard:
            // Remove exercises with no completed sets.
            workout.exercises.removeAll { exercise in
                exercise.sets.allSatisfy { !$0.completed }
            }
            // From remaining exercises, remove incomplete sets.
            for i in 0..<workout.exercises.count {
                workout.exercises[i].sets.removeAll { !$0.completed }
            }
        }

        restTimerViewModel.stopTimer()
        workout.duration = Date().timeIntervalSince(workout.date)

        let summary = workoutManager.completeWorkout()

        self.summaryData = summary
        self.workoutToSummarize = workout
        self.showSummary = true
    }

    private func cancelWorkout() {
        if let currentWorkout = workoutManager.currentWorkout {
            workoutManager.deleteWorkout(currentWorkout)
        }
        dismiss()
    }

    private func removeExercise(at offsets: IndexSet) {
        workout.exercises.remove(atOffsets: offsets)
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}

private extension ActiveWorkoutView {
    func addExercise() {
        triggerHapticFeedback()
        activeSheet = .exercisePicker
    }

    func finishWorkoutAction() {
        triggerHapticFeedback()
        if hasUnfinishedSets {
            self.alertInfo = AlertInfo(
                title: "Unfinished Sets",
                message: "You have unfinished sets. How would you like to proceed?",
                primaryButton: .default(Text("Complete Unfinished Sets")) {
                    finishWorkout(completionType: .autocomplete)
                },
                secondaryButton: .destructive(Text("Discard Unfinished Sets")) {
                    finishWorkout(completionType: .discard)
                }
            )
        } else {
            self.alertInfo = AlertInfo(
                title: "Finish Workout",
                message: "Are you sure you want to finish this workout?",
                primaryButton: .default(Text("Finish")) {
                    finishWorkout(completionType: .standard)
                },
                secondaryButton: .cancel()
            )
        }
        self.showingAlert = true
    }

    func cancelWorkoutAction() {
        triggerHapticFeedback()
        self.alertInfo = AlertInfo(
            title: "Cancel Workout",
            message: "Are you sure you want to cancel this workout? This action cannot be undone.",
            primaryButton: .destructive(Text("Confirm")) {
                cancelWorkout()
            },
            secondaryButton: .cancel()
        )
        self.showingAlert = true
    }

    func doneButtonAction() {
        triggerHapticFeedback()
        hideKeyboard()
    }
}

class RestTimerViewModel: ObservableObject {
    @Published var restTimeRemaining: TimeInterval = 0
    @Published var activeRestSetID: UUID?

    private var restTimer: Timer?
    private var audioPlayer: AVAudioPlayer?

    func startTimer(for set: WorkoutSet) {
        stopTimer()
        restTimeRemaining = set.restTime
        activeRestSetID = set.id
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.restTimeRemaining > 1 {
                self.restTimeRemaining -= 1
                if Int(self.restTimeRemaining.rounded()) == 10 {
                    self.playSound(named: "timer-warning")
                }
            } else {
                self.playSound(named: "timer-finished")
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        restTimer?.invalidate()
        restTimer = nil
        activeRestSetID = nil
        restTimeRemaining = 0
    }

    private func playSound(named: String) {
        guard let url = Bundle.main.url(forResource: named, withExtension: "wav") else {
            print("Error: Sound file `\(named).wav` not found in bundle.")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

        } catch {
            print("An unexpected error occurred while trying to play sound: \(error.localizedDescription)")
        }
    }
}

private struct WorkoutTimerView: View {
    let startDate: Date
    @State private var timeString: String = "00:00:00"
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(timeString)
            .onReceive(timer) { _ in
                let interval = Date().timeIntervalSince(startDate)
                let hours = Int(interval) / 3600
                let minutes = Int(interval) / 60 % 60
                let seconds = Int(interval) % 60
                timeString = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
            }
    }
}
