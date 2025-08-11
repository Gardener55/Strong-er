//
//  AIWorkoutView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/AIWorkoutView.swift
import SwiftUI

struct AIWorkoutView: View {
    @StateObject private var aiGenerator = AIWorkoutGenerator()
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var userProfile = UserProfile()
    @State private var generatedWorkout: Workout?
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Workout Generator")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tell us about your fitness goals and we'll create a personalized workout for you.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Profile Configuration
                    ProfileConfigurationView(profile: $userProfile)
                    
                    // Generate Button
                    Button(action: generateWorkout) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isGenerating ? "Generating..." : "Generate Workout")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isGenerating)
                    .buttonStyle(HapticButtonStyle())
                    
                    // Generated Workout
                    if let workout = generatedWorkout {
                        GeneratedWorkoutView(workout: workout) {
                            workoutManager.startWorkout(workout)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(HapticButtonStyle())
                }
            }
        }
    }
    
    private func generateWorkout() {
        isGenerating = true
        
        // Simulate AI processing time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            generatedWorkout = aiGenerator.generateWorkout(for: userProfile)
            isGenerating = false
        }
    }
}

struct ProfileConfigurationView: View {
    @Binding var profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Profile")
                .font(.headline)
            
            // Fitness Level
            VStack(alignment: .leading, spacing: 8) {
                Text("Fitness Level")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Fitness Level", selection: $profile.fitnessLevel) {
                    ForEach(UserProfile.FitnessLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Goals
            VStack(alignment: .leading, spacing: 8) {
                Text("Fitness Goals")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(UserProfile.FitnessGoal.allCases, id: \.self) { goal in
                        GoalToggle(goal: goal, isSelected: profile.goals.contains(goal)) {
                            if profile.goals.contains(goal) {
                                profile.goals.removeAll { $0 == goal }
                            } else {
                                profile.goals.append(goal)
                            }
                        }
                    }
                }
            }
            
            // Equipment
            VStack(alignment: .leading, spacing: 8) {
                Text("Available Equipment")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(Exercise.Equipment.allCases, id: \.self) { equipment in
                        EquipmentToggle(equipment: equipment, isSelected: profile.preferredEquipment.contains(equipment)) {
                            if profile.preferredEquipment.contains(equipment) {
                                profile.preferredEquipment.removeAll { $0 == equipment }
                            } else {
                                profile.preferredEquipment.append(equipment)
                            }
                        }
                    }
                }
            }
            
            // Session Duration
            VStack(alignment: .leading, spacing: 8) {
                Text("Session Duration: \(profile.sessionDuration) minutes")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Slider(value: Binding(
                    get: { Double(profile.sessionDuration) },
                    set: { profile.sessionDuration = Int($0) }
                ), in: 15...120, step: 15)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct GoalToggle: View {
    let goal: UserProfile.FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(goal.rawValue)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(HapticButtonStyle())
    }
}

struct EquipmentToggle: View {
    let equipment: Exercise.Equipment
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(equipment.rawValue)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.green : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(HapticButtonStyle())
    }
}

struct GeneratedWorkoutView: View {
    let workout: Workout
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Generated Workout")
                    .font(.headline)
                Spacer()
                Button("Start Workout", action: onStart)
                    .buttonStyle(HapticButtonStyle())
            }
            
            ForEach(workout.exercises) { exercise in
                ExercisePreviewRow(workoutExercise: exercise)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ExercisePreviewRow: View {
    let workoutExercise: WorkoutExercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workoutExercise.exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(workoutExercise.exercise.muscleGroups.map { $0.rawValue }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(workoutExercise.sets.count) sets")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}