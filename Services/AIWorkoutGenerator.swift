//
//  AIWorkoutGenerator.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Services/AIWorkoutGenerator.swift
import Foundation

class AIWorkoutGenerator: ObservableObject {
    private let exerciseDatabase = ExerciseDatabase.shared
    
    func generateWorkout(for profile: UserProfile) -> Workout {
        _ = profile.sessionDuration
        let fitnessLevel = profile.fitnessLevel
        let goals = profile.goals
        let equipment = profile.preferredEquipment
        
        var selectedExercises: [Exercise] = []
        
        // Filter exercises based on user preferences
        let availableExercises = exerciseDatabase.exercises.filter { exercise in
            // Check equipment availability
            let hasEquipment = equipment.isEmpty || equipment.contains(exercise.equipment)
            
            // Check difficulty level
            let appropriateDifficulty: Bool
            switch fitnessLevel {
            case .beginner:
                appropriateDifficulty = exercise.difficulty == .beginner
            case .intermediate:
                appropriateDifficulty = exercise.difficulty == .beginner || exercise.difficulty == .intermediate
            case .advanced:
                appropriateDifficulty = true
            }
            
            return hasEquipment && appropriateDifficulty
        }
        
        // Select exercises based on goals
        if goals.contains(.strength) || goals.contains(.muscleGain) {
            selectedExercises += selectStrengthExercises(from: availableExercises, count: 6)
        }
        
        if goals.contains(.endurance) || goals.contains(.weightLoss) {
            selectedExercises += selectCardioExercises(from: availableExercises, count: 3)
        }
        
        if goals.contains(.flexibility) {
            selectedExercises += selectFlexibilityExercises(from: availableExercises, count: 2)
        }
        
        // If no specific goals, create a balanced workout
        if selectedExercises.isEmpty {
            selectedExercises = createBalancedWorkout(from: availableExercises)
        }
        
        // Convert to workout exercises with appropriate sets/reps
        let workoutExercises = selectedExercises.map { exercise in
            createWorkoutExercise(from: exercise, fitnessLevel: fitnessLevel)
        }
        
        return Workout(
            name: "AI Generated Workout",
            exercises: workoutExercises,
            date: Date()
        )
    }
    
    private func selectStrengthExercises(from exercises: [Exercise], count: Int) -> [Exercise] {
        let strengthExercises = exercises.filter { $0.category == .strength }
        return Array(strengthExercises.shuffled().prefix(count))
    }
    
    private func selectCardioExercises(from exercises: [Exercise], count: Int) -> [Exercise] {
        let cardioExercises = exercises.filter { $0.category == .cardio }
        return Array(cardioExercises.shuffled().prefix(count))
    }
    
    private func selectFlexibilityExercises(from exercises: [Exercise], count: Int) -> [Exercise] {
        let flexibilityExercises = exercises.filter { $0.category == .flexibility }
        return Array(flexibilityExercises.shuffled().prefix(count))
    }
    
    private func createBalancedWorkout(from exercises: [Exercise]) -> [Exercise] {
        var balanced: [Exercise] = []
        
        // Add variety across muscle groups
        let chestExercises = exercises.filter { $0.muscleGroups.contains(.chest) }
        let backExercises = exercises.filter { $0.muscleGroups.contains(.back) }
        let legExercises = exercises.filter { $0.muscleGroups.contains(.legs) }
        let coreExercises = exercises.filter { $0.muscleGroups.contains(.core) }
        
        if let chest = chestExercises.randomElement() { balanced.append(chest) }
        if let back = backExercises.randomElement() { balanced.append(back) }
        if let legs = legExercises.randomElement() { balanced.append(legs) }
        if let core = coreExercises.randomElement() { balanced.append(core) }
        
        // Add cardio
        let cardio = exercises.filter { $0.category == .cardio }
        if let cardioExercise = cardio.randomElement() { balanced.append(cardioExercise) }
        
        return balanced
    }
    
    private func createWorkoutExercise(from exercise: Exercise, fitnessLevel: UserProfile.FitnessLevel) -> WorkoutExercise {
        let (sets, reps, weight) = getRecommendedVolume(for: exercise, fitnessLevel: fitnessLevel)
        
        let workoutSets = (0..<sets).map { _ in
            WorkoutSet(
                reps: reps,
                weight: weight,
                restTime: exercise.category == .cardio ? 30 : 60
            )
        }
        
        return WorkoutExercise(exercise: exercise, sets: workoutSets)
    }
    
    private func getRecommendedVolume(for exercise: Exercise, fitnessLevel: UserProfile.FitnessLevel) -> (sets: Int, reps: Int, weight: Double?) {
        switch exercise.category {
        case .strength:
            switch fitnessLevel {
            case .beginner:
                return (sets: 2, reps: 12, weight: nil)
            case .intermediate:
                return (sets: 3, reps: 10, weight: nil)
            case .advanced:
                return (sets: 4, reps: 8, weight: nil)
            }
        case .cardio:
            return (sets: 1, reps: 1, weight: nil) // Duration-based
        default:
            return (sets: 2, reps: 10, weight: nil)
        }
    }
}
