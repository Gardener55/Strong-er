//
//  WorkoutExercise.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Models/WorkoutExercise.swift
import Foundation

struct WorkoutExercise: Identifiable, Codable {
    let id = UUID()
    let exercise: Exercise
    var sets: [WorkoutSet]
    var notes: String = ""
    
    init(exercise: Exercise, sets: [WorkoutSet] = []) {
        self.exercise = exercise
        self.sets = sets.isEmpty ? [WorkoutSet()] : sets
    }
    
    var isCompleted: Bool {
        !sets.isEmpty && sets.allSatisfy { $0.completed }
    }
}