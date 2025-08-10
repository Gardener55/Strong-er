//
//  WorkoutExercise.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Models/WorkoutExercise.swift
import Foundation

struct WorkoutExercise: Identifiable, Codable {
    var id = UUID()
    var exercise: Exercise
    var sets: [WorkoutSet]
    var restTime: TimeInterval?
    var notes: String = ""
    
    init(exercise: Exercise, sets: [WorkoutSet] = [], restTime: TimeInterval? = nil) {
        self.exercise = exercise
        self.sets = sets.isEmpty ? [WorkoutSet()] : sets
        self.restTime = restTime
    }
    
    var isCompleted: Bool {
        !sets.isEmpty && sets.allSatisfy { $0.completed }
    }
}