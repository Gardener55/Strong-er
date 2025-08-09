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
                name: "Bench Press (Barbell)",
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
                name: "Incline Bench Press (Barbell)",
                category: .strength,
                muscleGroups: [.chest, .shoulders, .triceps],
                equipment: .barbell,
                description: "Variation of the bench press that targets the upper chest.",
                instructions: [
                    "Lie on an incline bench with feet flat on the floor.",
                    "Grip the barbell slightly wider than shoulder-width apart.",
                    "Lower the bar to your upper chest, then press it back up."
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
                name: "Deadlifts (Barbell)",
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
                name: "Squats (Barbell)",
                category: .strength,
                muscleGroups: [.legs, .glutes],
                equipment: .barbell,
                description: "Fundamental lower body exercise",
                instructions: [
                    "Stand with feet shoulder-width apart",
                    "Lower hips back and down",
                    "Return to standing position"
                ],
                difficulty: .beginner
            ),
            Exercise(
                name: "Front Squat (Barbell)",
                category: .strength,
                muscleGroups: [.legs, .glutes, .core],
                equipment: .barbell,
                description: "A squat variation that places more emphasis on the quadriceps.",
                instructions: [
                    "Hold the barbell across the front of your shoulders with a clean grip.",
                    "Squat down, keeping your chest up and elbows high.",
                    "Return to the starting position."
                ],
                difficulty: .intermediate
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
            
            // Shoulder Exercises
            Exercise(
                name: "Overhead Press (Barbell)",
                category: .strength,
                muscleGroups: [.shoulders, .triceps],
                equipment: .barbell,
                description: "A compound movement that develops shoulder strength.",
                instructions: [
                    "Stand with the barbell at the front of your shoulders, hands slightly wider than shoulder-width.",
                    "Press the barbell overhead until your arms are fully extended.",
                    "Lower the barbell back to your shoulders with control."
                ],
                difficulty: .intermediate
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
            ),
            // New Exercises from CSV
            Exercise(name: "AB Workout", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Around the World", category: .strength, muscleGroups: [.shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Arnold Curls", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Arnold Press (Dumbbell)", category: .strength, muscleGroups: [.shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Bent Over Deltoid Shrug", category: .strength, muscleGroups: [.back, .shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Bent Over One Arm Row (Dumbbell)", category: .strength, muscleGroups: [.back, .biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Bent Over Row (Barbell)", category: .strength, muscleGroups: [.back, .biceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Bent Over Row - Underhand (Barbell)", category: .strength, muscleGroups: [.back, .biceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Bent Over Shrug", category: .strength, muscleGroups: [.back], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Bicep Curl (Barbell)", category: .strength, muscleGroups: [.biceps], equipment: .barbell, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Bicep Curl (Cable)", category: .strength, muscleGroups: [.biceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Bicep Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Box Squat (Barbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Bulgarian Split Squat", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Cable Crunch", category: .strength, muscleGroups: [.core], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Cable Leg Extensions", category: .strength, muscleGroups: [.legs], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Cable Pull Through", category: .strength, muscleGroups: [.glutes], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Cable Twist", category: .strength, muscleGroups: [.core], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Calf Press on Leg Press", category: .strength, muscleGroups: [.calves], equipment: .machine, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Chest Dip", category: .strength, muscleGroups: [.chest, .triceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Chest Fly", category: .strength, muscleGroups: [.chest], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Chest Fly (Dumbbell)", category: .strength, muscleGroups: [.chest], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Chin Up", category: .strength, muscleGroups: [.back, .biceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Concentration Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Decline Bench Press (Barbell)", category: .strength, muscleGroups: [.chest, .triceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Decline Bench Press (Dumbbell)", category: .strength, muscleGroups: [.chest, .triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Decline Cable Fly", category: .strength, muscleGroups: [.chest], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Decline Crunch", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Decline Fly", category: .strength, muscleGroups: [.chest], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Flat Leg Raise", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Front Raise (Cable)", category: .strength, muscleGroups: [.shoulders], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Front Raise (Dumbbell)", category: .strength, muscleGroups: [.shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Front Raise (Plate)", category: .strength, muscleGroups: [.shoulders], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Goblet Squat (Kettlebell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .kettlebell, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Hammer Curl (Cable)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .cable, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Hammer Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Hip Thrust (Barbell)", category: .strength, muscleGroups: [.glutes, .legs], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Incline Bench Press (Dumbbell)", category: .strength, muscleGroups: [.chest, .shoulders, .triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Incline Cable Fly", category: .strength, muscleGroups: [.chest], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Incline Chest Fly (Dumbbell)", category: .strength, muscleGroups: [.chest], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Incline Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Incline Row (Dumbbell)", category: .strength, muscleGroups: [.back, .biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Inverted Row (Bodyweight)", category: .strength, muscleGroups: [.back, .biceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Kickbacks", category: .strength, muscleGroups: [.triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Knee Raise (Captain's Chair)", category: .strength, muscleGroups: [.core], equipment: .machine, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Landmine Calf Raises", category: .strength, muscleGroups: [.calves], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Landmine Chainsaw", category: .strength, muscleGroups: [.back], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Landmine Chest Press", category: .strength, muscleGroups: [.chest], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Landmine Lateral Raises", category: .strength, muscleGroups: [.shoulders], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Landmine Lunge", category: .strength, muscleGroups: [.legs, .glutes], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Landmine Romanian Deadlift", category: .strength, muscleGroups: [.legs, .glutes], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Landmine Shoulder Press", category: .strength, muscleGroups: [.shoulders], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Landmine Squat", category: .strength, muscleGroups: [.legs, .glutes], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Lat Pulldown (Cable)", category: .strength, muscleGroups: [.back, .biceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Lat Pulldown - Underhand (Cable)", category: .strength, muscleGroups: [.back, .biceps], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Lat Pulldown - Wide Grip (Cable)", category: .strength, muscleGroups: [.back], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Lateral Raise (Cable)", category: .strength, muscleGroups: [.shoulders], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Lateral Raise (Dumbbell)", category: .strength, muscleGroups: [.shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Laying Leg Curls", category: .strength, muscleGroups: [.legs], equipment: .machine, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Leg Extension (Machine)", category: .strength, muscleGroups: [.legs], equipment: .machine, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Leg Press", category: .strength, muscleGroups: [.legs, .glutes], equipment: .machine, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Lunge (Bodyweight)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Lunge (Dumbbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Lying Leg Curl (Machine)", category: .strength, muscleGroups: [.legs], equipment: .machine, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Overhead Press (Dumbbell)", category: .strength, muscleGroups: [.shoulders, .triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Outward Arm Swings (cable)", category: .strength, muscleGroups: [.shoulders], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Preacher Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Pull Up", category: .strength, muscleGroups: [.back, .biceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Pullover (Dumbbell)", category: .strength, muscleGroups: [.chest, .back], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Push Up", category: .strength, muscleGroups: [.chest, .triceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Rear Lunge", category: .strength, muscleGroups: [.legs, .glutes], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Reverse Curl (Barbell)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Reverse Curl (Cable)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Reverse Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Reverse Fly (Dumbbell)", category: .strength, muscleGroups: [.shoulders, .back], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Reverse Grip Concentration Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Reverse Incline Curl", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Romanian Deadlift (Dumbbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Russian Twist", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Seated Calf Raise (Plate Loaded)", category: .strength, muscleGroups: [.calves], equipment: .machine, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Seated Overhead Press (Barbell)", category: .strength, muscleGroups: [.shoulders, .triceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Seated Palms Up Wrist Curl (Dumbbell)", category: .strength, muscleGroups: [.forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Seated Row (Cable)", category: .strength, muscleGroups: [.back, .biceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Seated Wide-Grip Row (Cable)", category: .strength, muscleGroups: [.back], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Shrug (Barbell)", category: .strength, muscleGroups: [.back], equipment: .barbell, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Shrug (Dumbbell)", category: .strength, muscleGroups: [.back], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Side Bend (Dumbbell)", category: .strength, muscleGroups: [.core], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Sit Up", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Skullcrusher (Barbell)", category: .strength, muscleGroups: [.triceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Skullcrusher (Dumbbell)", category: .strength, muscleGroups: [.triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Squat (Bodyweight)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Squat (Dumbbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Standing Calf Raise (Barbell)", category: .strength, muscleGroups: [.calves], equipment: .barbell, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Standing Calf Raise (Dumbbell)", category: .strength, muscleGroups: [.calves], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Standing Calf Raise (Machine)", category: .strength, muscleGroups: [.calves], equipment: .machine, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Stiff Leg Deadlift (Dumbbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Strict Military Press (Barbell)", category: .strength, muscleGroups: [.shoulders, .triceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Superman", category: .strength, muscleGroups: [.back], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "T Bar Row", category: .strength, muscleGroups: [.back, .biceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Triceps Dip", category: .strength, muscleGroups: [.triceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Triceps Extension (Cable)", category: .strength, muscleGroups: [.triceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Triceps Extension (Dumbbell)", category: .strength, muscleGroups: [.triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Triceps Pushdown (Cable - Straight Bar)", category: .strength, muscleGroups: [.triceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner),
            Exercise(name: "Upright Row (Cable)", category: .strength, muscleGroups: [.shoulders, .biceps], equipment: .cable, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Upright Row (Dumbbell)", category: .strength, muscleGroups: [.shoulders, .biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate),
            Exercise(name: "Wrist Roller", category: .strength, muscleGroups: [.forearms], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate)
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
