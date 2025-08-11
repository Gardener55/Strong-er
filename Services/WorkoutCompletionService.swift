//
//  WorkoutCompletionService.swift
//  Strong-er
//
//  Created by Jules on 8/11/25.
//

import Foundation

struct WorkoutCompletionService {

    /// Processes a completed workout to update the user's profile with new strength data and recovery information.
    /// - Parameters:
    ///   - profile: The user's current profile.
    ///   - workout: The workout that was just completed.
    /// - Returns: An updated `UserProfile` with new e1RM values and last trained dates.
    static func processCompletedWorkout(profile: UserProfile, workout: Workout) -> UserProfile {
        var updatedProfile = profile

        // Keep track of which muscle groups were trained in this session
        var trainedGroupsInSession = Set<Exercise.MuscleGroup>()

        for workoutExercise in workout.exercises {
            // We only need to update e1RM for strength exercises
            guard workoutExercise.exercise.category == .strength else { continue }

            // Find the best set (highest weight for a valid number of reps) to calculate the new e1RM from.
            var bestSet: WorkoutSet?
            var maxWeight: Double = 0.0

            for set in workoutExercise.sets {
                // We need both weight and reps to calculate e1RM.
                guard let weight = set.weight, set.reps > 0 else { continue }

                if weight >= maxWeight {
                    maxWeight = weight
                    bestSet = set
                }
            }

            // If we found a valid set, calculate and update the e1RM
            if let bestSet = bestSet, let weight = bestSet.weight {
                let newE1RM = WorkoutScience.calculateE1RM(weight: weight, reps: bestSet.reps)

                // Update the e1RM, but only if it's an improvement to avoid penalizing a bad day.
                let currentE1RM = updatedProfile.estimatedOneRepMax[workoutExercise.exercise.name] ?? 0.0
                if newE1RM > currentE1RM {
                    updatedProfile.estimatedOneRepMax[workoutExercise.exercise.name] = newE1RM
                }
            }

            // Mark the target muscle group as trained in this session
            trainedGroupsInSession.insert(workoutExercise.exercise.targetMuscleGroup)
        }

        // Update the last trained date for all muscle groups hit in this workout
        for group in trainedGroupsInSession {
            updatedProfile.lastTrainedMuscleGroups[group] = workout.date
        }

        return updatedProfile
    }
}
