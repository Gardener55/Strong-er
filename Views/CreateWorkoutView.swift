//
//  CreateWorkoutView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/CreateWorkoutView.swift
import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var exerciseDatabase: ExerciseDatabase
    
    @State private var workoutName = ""
    @State private var selectedExercises: [WorkoutExercise] = []
    @State private var showingExercisePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Workout Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Name")
                        .font(.headline)
                    
                    TextField("Enter workout name", text: $workoutName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Exercise List
                List {
                    ForEach(selectedExercises) { exercise in
                        WorkoutExerciseRow(workoutExercise: exercise) { updatedExercise in
                            if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                                selectedExercises[index] = updatedExercise
                            }
                        }
                    }
                    .onDelete(perform: removeExercises)
                    
                    // Add Exercise Button
                    Button(action: { showingExercisePicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Exercise")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty || selectedExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { exercise in
                    let workoutExercise = WorkoutExercise(exercise: exercise)
                    selectedExercises.append(workoutExercise)
                }
            }
        }
    }
    
    private func removeExercises(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }
    
    private func saveWorkout() {
        let workout = Workout(name: workoutName, exercises: selectedExercises)
        workoutManager.saveTemplate(workout)
        dismiss()
    }
}

struct WorkoutExerciseRow: View {
    let workoutExercise: WorkoutExercise
    let onUpdate: (WorkoutExercise) -> Void
    
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workoutExercise.exercise.name)
                    .font(.headline)
                
                Spacer()
                
                Button("Edit") {
                    showingDetail = true
                }
                .font(.caption)
            }
            
            Text("\(workoutExercise.sets.count) sets")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showingDetail) {
            ExerciseSetupView(workoutExercise: workoutExercise, onSave: onUpdate)
        }
    }
}

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var exerciseDatabase: ExerciseDatabase
    let onExerciseSelected: (Exercise) -> Void
    
    @State private var searchText = ""
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exerciseDatabase.exercises
        }
        return exerciseDatabase.searchExercises(searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                
                List(filteredExercises) { exercise in
                    Button(action: {
                        onExerciseSelected(exercise)
                        dismiss()
                    }) {
                        ExerciseRow(exercise: exercise)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExerciseSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutExercise: WorkoutExercise
    let onSave: (WorkoutExercise) -> Void
    
    init(workoutExercise: WorkoutExercise, onSave: @escaping (WorkoutExercise) -> Void) {
        _workoutExercise = State(initialValue: workoutExercise)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(Array(workoutExercise.sets.enumerated()), id: \.offset) { index, set in
                        SetRow(
                            setNumber: index + 1,
                            set: set
                        ) { updatedSet in
                            workoutExercise.sets[index] = updatedSet
                        }
                    }
                    .onDelete(perform: removeSets)
                    
                    Button("Add Set") {
                        workoutExercise.sets.append(WorkoutSet())
                    }
                }
            }
            .navigationTitle(workoutExercise.exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(workoutExercise)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func removeSets(at offsets: IndexSet) {
        workoutExercise.sets.remove(atOffsets: offsets)
    }
}

struct SetRow: View {
    let setNumber: Int
    @State private var set: WorkoutSet
    let onUpdate: (WorkoutSet) -> Void
    
    init(setNumber: Int, set: WorkoutSet, onUpdate: @escaping (WorkoutSet) -> Void) {
        self.setNumber = setNumber
        _set = State(initialValue: set)
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        HStack {
            Text("Set \(setNumber)")
                .font(.caption)
                .frame(width: 50, alignment: .leading)
            
            VStack {
                Text("Reps")
                    .font(.caption2)
                TextField("0", value: $set.reps, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            
            if set.weight != nil {
                VStack {
                    Text("Weight")
                        .font(.caption2)
                    TextField("0", value: Binding(
                        get: { set.weight ?? 0 },
                        set: { set.weight = $0 }
                    ), format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                }
            }
            
            VStack {
                Text("Rest (s)")
                    .font(.caption2)
                TextField("60", value: Binding(
                    get: { Int(set.restTime) },
                    set: { set.restTime = TimeInterval($0) }
                ), format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            }
        }
        .onChange(of: set) { _ in
            onUpdate(set)
        }
    }
}