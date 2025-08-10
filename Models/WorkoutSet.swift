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
    var isWarmup: Bool = false
    
    init(reps: Int = 0, weight: Double? = nil, duration: TimeInterval? = nil, distance: Double? = nil, restTime: TimeInterval = 60, isWarmup: Bool = false) {
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.distance = distance
        self.restTime = restTime
        self.isWarmup = isWarmup
    }

    enum CodingKeys: String, CodingKey {
        case id, reps, weight, duration, distance, restTime, completed, isWarmup
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        restTime = try container.decode(TimeInterval.self, forKey: .restTime)
        completed = try container.decode(Bool.self, forKey: .completed)
        isWarmup = (try? container.decode(Bool.self, forKey: .isWarmup)) ?? false
    }
}