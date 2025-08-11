//
//  ExerciseLibraryView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/ExerciseLibraryView.swift
import SwiftUI

struct ExerciseLibraryView: View {
    @EnvironmentObject var exerciseDatabase: ExerciseDatabase
    @State private var searchText = ""
    @State private var selectedCategory: Exercise.ExerciseCategory?
    @State private var selectedMuscleGroup: Exercise.MuscleGroup?
    
    var filteredExercises: [Exercise] {
        var exercises = exerciseDatabase.exercises
        
        if !searchText.isEmpty {
            exercises = exerciseDatabase.searchExercises(searchText)
        }
        
        if let category = selectedCategory {
            exercises = exercises.filter { $0.category == category }
        }
        
        if let muscleGroup = selectedMuscleGroup {
            exercises = exercises.filter { $0.muscleGroups.contains(muscleGroup) }
        }
        
        return exercises
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                
                // Filters
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(
                                title: "All Categories",
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }

                            ForEach(Exercise.ExerciseCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(
                                title: "All Muscle Groups",
                                isSelected: selectedMuscleGroup == nil
                            ) {
                                selectedMuscleGroup = nil
                            }

                            ForEach(Exercise.MuscleGroup.allCases, id: \.self) { muscleGroup in
                                FilterChip(
                                    title: muscleGroup.rawValue,
                                    isSelected: selectedMuscleGroup == muscleGroup
                                ) {
                                    selectedMuscleGroup = selectedMuscleGroup == muscleGroup ? nil : muscleGroup
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Exercise List
                List(filteredExercises) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        ExerciseRow(exercise: exercise)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Exercise Library")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search exercises...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(HapticButtonStyle())
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                Text(exercise.muscleGroups.map { $0.rawValue }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label(exercise.category.rawValue, systemImage: categoryIcon(exercise.category))
                    Label(exercise.equipment.rawValue, systemImage: "dumbbell")
                    Label(exercise.difficulty.rawValue, systemImage: difficultyIcon(exercise.difficulty))
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func categoryIcon(_ category: Exercise.ExerciseCategory) -> String {
        switch category {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        case .balance: return "figure.mind.and.body"
        case .plyometric: return "figure.jumprope"
        }
    }
    
    private func difficultyIcon(_ difficulty: Exercise.Difficulty) -> String {
        switch difficulty {
        case .beginner: return "star"
        case .intermediate: return "star.fill"
        case .advanced: return "star.circle.fill"
        }
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingAddToWorkout = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(exercise.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Exercise Info
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    InfoCard(title: "Category", value: exercise.category.rawValue, icon: "tag")
                    InfoCard(title: "Equipment", value: exercise.equipment.rawValue, icon: "dumbbell")
                    InfoCard(title: "Difficulty", value: exercise.difficulty.rawValue, icon: "star")
                    InfoCard(title: "Muscle Groups", value: exercise.muscleGroups.map { $0.rawValue }.joined(separator: ", "), icon: "figure.arms.open")
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.headline)
                    
                    ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.blue)
                                .clipShape(Circle())
                            
                            Text(instruction)
                                .font(.body)
                            
                            Spacer()
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add to Workout") {
                    showingAddToWorkout = true
                }
                .buttonStyle(HapticButtonStyle())
            }
        }
        .sheet(isPresented: $showingAddToWorkout) {
            AddExerciseToWorkoutView(exercise: exercise)
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}