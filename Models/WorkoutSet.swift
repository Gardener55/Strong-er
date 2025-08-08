//
//  WorkoutSet.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Models/WorkoutSet.swift
import Foundation

struct WorkoutSet: Identifiable, Codable, Equatable {
    var id = UUID()
    var reps: Int
    var weight: Double?
    var duration: TimeInterval?
    var distance: Double?
    var restTime: TimeInterval
    var completed: Bool = false
    
    init(reps: Int = 0, weight: Double? = nil, duration: TimeInterval? = nil, distance: Double? = nil, restTime: TimeInterval = 60) {
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.distance = distance
        self.restTime = restTime
    }
}