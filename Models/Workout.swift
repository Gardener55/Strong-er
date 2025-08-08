//
//  Workout.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Models/Workout.swift
import Foundation

struct Workout: Identifiable, Codable {
    let id = UUID()
    var name: String
    var exercises: [WorkoutExercise]
    var date: Date
    var duration: TimeInterval?
    var notes: String = ""
    var isTemplate: Bool = false
    
    init(name: String, exercises: [WorkoutExercise] = [], date: Date = Date(), isTemplate: Bool = false) {
        self.name = name
        self.exercises = exercises
        self.date = date
        self.isTemplate = isTemplate
    }
    
    var isCompleted: Bool {
        !exercises.isEmpty && exercises.allSatisfy { $0.isCompleted }
    }
    
    var completedExercises: Int {
        exercises.filter { $0.isCompleted }.count
    }
}