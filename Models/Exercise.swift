//
//  Exercise.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/8/25.
//


// Models/Exercise.swift
import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let category: ExerciseCategory
    let muscleGroups: [MuscleGroup]
    let equipment: Equipment
    let description: String
    let instructions: [String]
    let difficulty: Difficulty
    let exerciseType: ExerciseType // New property
    let targetMuscleGroup: MuscleGroup // New property
    
    enum ExerciseType: String, CaseIterable, Codable, Equatable {
        case primary = "Primary"
        case accessory = "Accessory"
        case warmup = "Warm-up"
        case cooldown = "Cool-down"
    }

    enum ExerciseCategory: String, CaseIterable, Codable, Equatable {
        case strength = "Strength"
        case cardio = "Cardio"
        case flexibility = "Flexibility"
        case balance = "Balance"
        case plyometric = "Plyometric"
    }
    
    enum MuscleGroup: String, CaseIterable, Codable, Equatable {
        case chest = "Chest"
        case back = "Back"
        case shoulders = "Shoulders"
        case biceps = "Biceps"
        case triceps = "Triceps"
        case legs = "Legs"
        case glutes = "Glutes"
        case core = "Core"
        case calves = "Calves"
        case forearms = "Forearms"
    }
    
    enum Equipment: String, CaseIterable, Codable, Equatable {
        case bodyweight = "Bodyweight"
        case dumbbells = "Dumbbells"
        case barbell = "Barbell"
        case resistance = "Resistance Bands"
        case machine = "Machine"
        case kettlebell = "Kettlebell"
        case cable = "Cable"
    }
    
    enum Difficulty: String, CaseIterable, Codable, Equatable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}