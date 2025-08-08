//
//  ExerciseDatabase.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Services/ExerciseDatabase.swift
import Foundation

class ExerciseDatabase: ObservableObject {
    static let shared = ExerciseDatabase()
    
    @Published var exercises: [Exercise] = []
    
    private init() {
        loadExercises()
    }
    
    private func loadExercises() {
        exercises = [
            // Chest Exercises
            Exercise(
                name: "Push-ups",
                category: .strength,
                muscleGroups: [.chest, .triceps, .shoulders],
                equipment: .bodyweight,
                description: "Classic bodyweight chest exercise",
                instructions: [
                    "Start in a plank position with hands slightly wider than shoulders",
                    "Lower your chest to the ground",
                    "Push back up to starting position"
                ],
                difficulty: .beginner
            ),
            Exercise(
                name: "Bench Press",
                category: .strength,
                muscleGroups: [.chest, .triceps, .shoulders],
                equipment: .barbell,
                description: "Fundamental chest building exercise",
                instructions: [
                    "Lie on bench with feet flat on floor",
                    "Grip barbell slightly wider than shoulders",
                    "Lower bar to chest, then press up"
                ],
                difficulty: .intermediate
            ),
            Exercise(
                name: "Dumbbell Flyes",
                category: .strength,
                muscleGroups: [.chest],
                equipment: .dumbbells,
                description: "Isolation exercise for chest development",
                instructions: [
                    "Lie on bench holding dumbbells above chest",
                    "Lower weights in arc motion",
                    "Squeeze chest muscles to return to start"
                ],
                difficulty: .intermediate
            ),
            
            // Back Exercises
            Exercise(
                name: "Pull-ups",
                category: .strength,
                muscleGroups: [.back, .biceps],
                equipment: .bodyweight,
                description: "Upper body pulling exercise",
                instructions: [
                    "Hang from pull-up bar with palms facing away",
                    "Pull body up until chin clears bar",
                    "Lower with control"
                ],
                difficulty: .intermediate
            ),
            Exercise(
                name: "Deadlifts",
                category: .strength,
                muscleGroups: [.back, .legs, .glutes],
                equipment: .barbell,
                description: "Compound full-body exercise",
                instructions: [
                    "Stand with feet hip-width apart",
                    "Bend at hips and knees to grip barbell",
                    "Stand up straight, lifting the weight"
                ],
                difficulty: .advanced
            ),
            
            // Leg Exercises
            Exercise(
                name: "Squats",
                category: .strength,
                muscleGroups: [.legs, .glutes],
                equipment: .bodyweight,
                description: "Fundamental lower body exercise",
                instructions: [
                    "Stand with feet shoulder-width apart",
                    "Lower hips back and down",
                    "Return to standing position"
                ],
                difficulty: .beginner
            ),
            Exercise(
                name: "Lunges",
                category: .strength,
                muscleGroups: [.legs, .glutes],
                equipment: .bodyweight,
                description: "Unilateral leg strengthening exercise",
                instructions: [
                    "Step forward into lunge position",
                    "Lower back knee toward ground",
                    "Push back to starting position"
                ],
                difficulty: .beginner
            ),
            
            // Cardio Exercises
            Exercise(
                name: "Running",
                category: .cardio,
                muscleGroups: [.legs, .core],
                equipment: .bodyweight,
                description: "Cardiovascular endurance exercise",
                instructions: [
                    "Maintain steady pace",
                    "Land on midfoot",
                    "Keep relaxed posture"
                ],
                difficulty: .beginner
            ),
            Exercise(
                name: "Burpees",
                category: .cardio,
                muscleGroups: [.chest, .legs, .core],
                equipment: .bodyweight,
                description: "High-intensity full body exercise",
                instructions: [
                    "Start standing, drop to squat",
                    "Jump back to plank position",
                    "Do push-up, jump feet forward, jump up"
                ],
                difficulty: .advanced
            ),
            
            // Core Exercises
            Exercise(
                name: "Plank",
                category: .strength,
                muscleGroups: [.core],
                equipment: .bodyweight,
                description: "Isometric core strengthening exercise",
                instructions: [
                    "Hold push-up position",
                    "Keep body straight from head to heels",
                    "Engage core muscles"
                ],
                difficulty: .beginner
            )
        ]
    }
    
    func getExercises(for category: Exercise.ExerciseCategory) -> [Exercise] {
        exercises.filter { $0.category == category }
    }
    
    func getExercises(for muscleGroup: Exercise.MuscleGroup) -> [Exercise] {
        exercises.filter { $0.muscleGroups.contains(muscleGroup) }
    }
    
    func searchExercises(_ query: String) -> [Exercise] {
        if query.isEmpty {
            return exercises
        }
        return exercises.filter { 
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.muscleGroups.contains { $0.rawValue.localizedCaseInsensitiveContains(query) }
        }
    }
}