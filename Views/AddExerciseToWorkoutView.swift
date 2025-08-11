//
//  AddExerciseToWorkoutView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/AddExerciseToWorkoutView.swift
import SwiftUI

struct AddExerciseToWorkoutView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State private var selectedTemplate: Workout?
    @State private var showingNewWorkout = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Exercise Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add to Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Options
                VStack(spacing: 12) {
                    if workoutManager.currentWorkout != nil {
                        Button("Add to Current Workout") {
                            addToCurrentWorkout()
                        }
                        .buttonStyle(HapticButtonStyle())
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button("Create New Workout") {
                        showingNewWorkout = true
                    }
                    .buttonStyle(HapticButtonStyle())
                    .frame(maxWidth: .infinity)
                    
                    if !workoutManager.templates.isEmpty {
                        Text("Or add to template:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(workoutManager.templates.prefix(3)) { template in
                            Button(template.name) {
                                addToTemplate(template)
                            }
                            .buttonStyle(HapticButtonStyle())
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(HapticButtonStyle())
                }
            }
        }
        .sheet(isPresented: $showingNewWorkout) {
            CreateWorkoutView()
        }
    }
    
    private func addToCurrentWorkout() {
        guard var currentWorkout = workoutManager.currentWorkout else { return }
        let workoutExercise = WorkoutExercise(exercise: exercise)
        currentWorkout.exercises.append(workoutExercise)
        workoutManager.currentWorkout = currentWorkout
        dismiss()
    }
    
    private func addToTemplate(_ template: Workout) {
        // Implementation for adding to template
        dismiss()
    }
}