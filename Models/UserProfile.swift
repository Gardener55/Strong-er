//
//  UserProfile.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Models/UserProfile.swift
import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var age: Int = 25
    var weight: Double = 70.0
    var height: Double = 170.0
    var fitnessLevel: FitnessLevel = .beginner
    var goals: [FitnessGoal] = []
    var preferredEquipment: [Exercise.Equipment] = []
    var workoutDaysPerWeek: Int = 3
    var sessionDuration: Int = 60 // minutes
    var weightUnit: WeightUnit = .kilograms

    enum WeightUnit: String, CaseIterable, Codable, Equatable {
        case kilograms = "kg"
        case pounds = "lbs"
    }
    
    enum FitnessLevel: String, CaseIterable, Codable, Equatable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
    
    enum FitnessGoal: String, CaseIterable, Codable, Equatable {
        case weightLoss = "Weight Loss"
        case muscleGain = "Muscle Gain"
        case strength = "Strength"
        case endurance = "Endurance"
        case flexibility = "Flexibility"
        case general = "General Fitness"
    }
}