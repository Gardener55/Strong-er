//
//  AIWorkoutGenerator.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/8/25, updated by Jules.
//

import Foundation

class AIWorkoutGenerator: ObservableObject {
    private let exerciseDatabase = ExerciseDatabase.shared

    /// Generates a scientifically-backed workout based on the user's profile and a target muscle group.
    /// - Parameters:
    ///   - profile: The user's profile containing goals, history, and stats.
    ///   - targetGroup: The primary muscle group to focus on for this workout.
    /// - Returns: A structured `Workout` object or `nil` if the muscle group is still in recovery.
    func generateWorkout(for profile: UserProfile, for targetGroup: Exercise.MuscleGroup) -> Workout? {
        // 1. Recovery Check
        if let lastTrainedDate = profile.lastTrainedMuscleGroups[targetGroup] {
            // 48 hours = 172800 seconds
            if Date().timeIntervalSince(lastTrainedDate) < 172800 {
                print("Muscle group \(targetGroup.rawValue) is still recovering. Please rest.")
                return nil // In a real app, this would be a user-facing error/alert.
            }
        }

        // 2. Get Goal Parameters
        let primaryGoal = profile.goals.first ?? .general
        let goalParams = WorkoutScience.getParameters(for: primaryGoal)
        
        // 3. Select Exercises based on Structure
        var selectedExercises: [Exercise] = []
        
        // Filter exercises by user's available equipment
        let availableExercises = exerciseDatabase.exercises.filter { exercise in
            profile.preferredEquipment.isEmpty || profile.preferredEquipment.contains(exercise.equipment)
        }
        
        // Warm-up (1-2 exercises)
        selectedExercises += selectExercises(from: availableExercises, type: .warmup, count: 2)
        
        // Primary Lifts (1-2 exercises)
        let primaryExercises = availableExercises.filter { $0.targetMuscleGroup == targetGroup && $0.exerciseType == .primary }
        selectedExercises += primaryExercises.shuffled().prefix(2)

        // Accessory Lifts (2-3 exercises)
        let accessoryExercises = availableExercises.filter { $0.targetMuscleGroup == targetGroup && $0.exerciseType == .accessory }
        selectedExercises += accessoryExercises.shuffled().prefix(3)
        
        // Cool-down (1-2 exercises)
        selectedExercises += selectExercises(from: availableExercises, type: .cooldown, count: 2)

        // 4. Create WorkoutExercises with calculated volume
        let workoutExercises = selectedExercises.map { exercise -> WorkoutExercise in
            // For warm-ups and cool-downs, use a standard light routine
            if exercise.exerciseType == .warmup || exercise.exerciseType == .cooldown {
                let lightSet = WorkoutSet(reps: 10, weight: nil, restTime: 30)
                return WorkoutExercise(exercise: exercise, sets: [lightSet])
            }

            // For strength exercises, calculate weight based on e1RM
            let e1RM = profile.estimatedOneRepMax[exercise.name] ?? 45.0 // Default to empty bar if no e1RM

            // Apply progressive overload if this isn't the first time
            // A simple proxy: if e1RM is not the default, we've done it before.
            let targetE1RM = (e1RM > 45.0) ? (e1RM * WorkoutScience.overloadFactor) : e1RM

            // Calculate weight based on intensity for the user's goal
            let targetIntensity = (goalParams.intensityRange.lowerBound + goalParams.intensityRange.upperBound) / 2.0
            var targetWeight = targetE1RM * targetIntensity

            // Round weight to the nearest 5lbs, a common practice
            targetWeight = (targetWeight / 5.0).rounded() * 5.0

            let targetReps = goalParams.repRange.randomElement() ?? goalParams.repRange.lowerBound

            let workoutSets = (0..<goalParams.sets).map { _ in
                WorkoutSet(reps: targetReps, weight: targetWeight, restTime: 60)
            }

            return WorkoutExercise(exercise: exercise, sets: workoutSets)
        }
        
        return Workout(
            name: "AI: \(targetGroup.rawValue) Day (\(primaryGoal.rawValue))",
            exercises: workoutExercises,
            date: Date()
        )
    }
    
    private func selectExercises(from exercises: [Exercise], type: Exercise.ExerciseType, count: Int) -> [Exercise] {
        let filtered = exercises.filter { $0.exerciseType == type }
        return Array(filtered.shuffled().prefix(count))
    }

    /// Generates a standardized workout to assess the user's initial strength levels.
    func generateAssessmentWorkout() -> Workout {
        let assessmentExerciseNames = [
            "Bench Press (Barbell)",
            "Squats (Barbell)",
            "Deadlift (Barbell)",
            "Overhead Press (Barbell)"
        ]

        let workoutExercises = assessmentExerciseNames.compactMap { name in
            exerciseDatabase.exercises.first { $0.name == name }
        }.map { exercise -> WorkoutExercise in
            // For an assessment, we prescribe one set. The user should aim for 5-8 reps
            // with a challenging weight to establish a baseline e1RM.
            let assessmentSet = WorkoutSet(reps: 8, weight: 45.0, restTime: 180) // Placeholder weight
            return WorkoutExercise(exercise: exercise, sets: [assessmentSet])
        }

        return Workout(
            name: "Initial Strength Assessment",
            exercises: workoutExercises,
            date: Date()
        )
    }
}
