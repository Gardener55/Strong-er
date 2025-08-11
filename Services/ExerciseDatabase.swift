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
            // Warm-up
            Exercise(
                name: "Jumping Jacks",
                category: .cardio,
                muscleGroups: [.legs, .shoulders, .core],
                equipment: .bodyweight,
                description: "A full-body dynamic warm-up exercise.",
                instructions: ["Stand with feet together and hands at your sides.", "Jump up while spreading your feet and bringing your hands overhead.", "Return to the starting position."],
                difficulty: .beginner,
                exerciseType: .warmup,
                targetMuscleGroup: .legs
            ),
            Exercise(
                name: "Arm Circles",
                category: .flexibility,
                muscleGroups: [.shoulders],
                equipment: .bodyweight,
                description: "A simple warm-up to increase shoulder mobility.",
                instructions: ["Stand with arms extended to your sides.", "Make small circles, gradually increasing the size.", "Reverse direction after 30 seconds."],
                difficulty: .beginner,
                exerciseType: .warmup,
                targetMuscleGroup: .shoulders
            ),

            // Cool-down
            Exercise(
                name: "Quad Stretch",
                category: .flexibility,
                muscleGroups: [.legs],
                equipment: .bodyweight,
                description: "A static stretch for the quadriceps.",
                instructions: ["Stand on one leg, holding onto something for balance if needed.", "Pull your other foot towards your glute.", "Hold for 30 seconds and switch legs."],
                difficulty: .beginner,
                exerciseType: .cooldown,
                targetMuscleGroup: .legs
            ),
            Exercise(
                name: "Hamstring Stretch",
                category: .flexibility,
                muscleGroups: [.legs],
                equipment: .bodyweight,
                description: "A static stretch for the hamstrings.",
                instructions: ["Sit on the floor with one leg extended.", "Bend the other leg so the sole of your foot touches your inner thigh.", "Reach towards your extended foot.", "Hold for 30 seconds and switch legs."],
                difficulty: .beginner,
                exerciseType: .cooldown,
                targetMuscleGroup: .legs
            ),

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
                difficulty: .beginner,
                exerciseType: .accessory,
                targetMuscleGroup: .chest
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
                difficulty: .intermediate,
                exerciseType: .primary,
                targetMuscleGroup: .chest
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
                difficulty: .intermediate,
                exerciseType: .primary,
                targetMuscleGroup: .chest
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
                difficulty: .intermediate,
                exerciseType: .accessory,
                targetMuscleGroup: .chest
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
                difficulty: .intermediate,
                exerciseType: .primary,
                targetMuscleGroup: .back
            ),
            Exercise(
                name: "Deadlift (Barbell)",
                category: .strength,
                muscleGroups: [.back, .legs, .glutes],
                equipment: .barbell,
                description: "Compound full-body exercise",
                instructions: [
                    "Stand with feet hip-width apart",
                    "Bend at hips and knees to grip barbell",
                    "Stand up straight, lifting the weight"
                ],
                difficulty: .advanced,
                exerciseType: .primary,
                targetMuscleGroup: .back
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
                difficulty: .beginner,
                exerciseType: .primary,
                targetMuscleGroup: .legs
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
                difficulty: .intermediate,
                exerciseType: .primary,
                targetMuscleGroup: .legs
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
                difficulty: .beginner,
                exerciseType: .accessory,
                targetMuscleGroup: .legs
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
                difficulty: .intermediate,
                exerciseType: .primary,
                targetMuscleGroup: .shoulders
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
                difficulty: .beginner,
                exerciseType: .primary,
                targetMuscleGroup: .legs
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
                difficulty: .advanced,
                exerciseType: .primary,
                targetMuscleGroup: .chest
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
                difficulty: .beginner,
                exerciseType: .accessory,
                targetMuscleGroup: .core
            ),
            // New Exercises from CSV
            Exercise(name: "AB Workout", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Around the World", category: .strength, muscleGroups: [.shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Arnold Curls", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Arnold Press (Dumbbell)", category: .strength, muscleGroups: [.shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Bent Over Deltoid Shrug", category: .strength, muscleGroups: [.back, .shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Bent Over Row (Dumbbell)", category: .strength, muscleGroups: [.back, .biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Bent Over Row (Barbell)", category: .strength, muscleGroups: [.back, .biceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .back),
            Exercise(name: "Bent Over Row - Underhand (Barbell)", category: .strength, muscleGroups: [.back, .biceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .back),
            Exercise(name: "Bent Over Shrug", category: .strength, muscleGroups: [.back], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Bicep Curl (Barbell)", category: .strength, muscleGroups: [.biceps], equipment: .barbell, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Bicep Curl (Cable)", category: .strength, muscleGroups: [.biceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Bicep Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Box Squat (Barbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .legs),
            Exercise(name: "Bulgarian Split Squat", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Cable Crunch", category: .strength, muscleGroups: [.core], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Cable Leg Extensions", category: .strength, muscleGroups: [.legs], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Cable Pull Through", category: .strength, muscleGroups: [.glutes], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .glutes),
            Exercise(name: "Cable Twist", category: .strength, muscleGroups: [.core], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Calf Press on Leg Press", category: .strength, muscleGroups: [.calves], equipment: .machine, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .calves),
            Exercise(name: "Chest Dip", category: .strength, muscleGroups: [.chest, .triceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Chest Fly", category: .strength, muscleGroups: [.chest], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Chest Fly (Dumbbell)", category: .strength, muscleGroups: [.chest], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Chin Up", category: .strength, muscleGroups: [.back, .biceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .back),
            Exercise(name: "Concentration Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Decline Bench Press (Barbell)", category: .strength, muscleGroups: [.chest, .triceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .chest),
            Exercise(name: "Decline Bench Press (Dumbbell)", category: .strength, muscleGroups: [.chest, .triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Decline Cable Fly", category: .strength, muscleGroups: [.chest], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Decline Crunch", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Decline Fly", category: .strength, muscleGroups: [.chest], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Flat Leg Raise", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Face Pull (Cable)", category: .strength, muscleGroups: [.shoulders], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Front Raise (Cable)", category: .strength, muscleGroups: [.shoulders], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Front Raise (Dumbbell)", category: .strength, muscleGroups: [.shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Front Raise (Plate)", category: .strength, muscleGroups: [.shoulders], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Goblet Squat (Kettlebell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .kettlebell, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Hammer Curl (Cable)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .cable, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Hammer Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Hip Thrust (Barbell)", category: .strength, muscleGroups: [.glutes, .legs], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .glutes),
            Exercise(name: "Incline Bench Press (Dumbbell)", category: .strength, muscleGroups: [.chest, .shoulders, .triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Incline Cable Fly", category: .strength, muscleGroups: [.chest], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Incline Chest Fly (Dumbbell)", category: .strength, muscleGroups: [.chest], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Incline Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Incline Row (Dumbbell)", category: .strength, muscleGroups: [.back, .biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Inverted Row (Bodyweight)", category: .strength, muscleGroups: [.back, .biceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Kickbacks", category: .strength, muscleGroups: [.triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .triceps),
            Exercise(name: "Knee Raise (Captain's Chair)", category: .strength, muscleGroups: [.core], equipment: .machine, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Landmine Calf Raises", category: .strength, muscleGroups: [.calves], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .calves),
            Exercise(name: "Landmine Chainsaw", category: .strength, muscleGroups: [.back], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Landmine Chest Press", category: .strength, muscleGroups: [.chest], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Landmine Lateral Raises", category: .strength, muscleGroups: [.shoulders], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Landmine Lunge", category: .strength, muscleGroups: [.legs, .glutes], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Landmine Romanian Deadlift", category: .strength, muscleGroups: [.legs, .glutes], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Landmine Shoulder Press", category: .strength, muscleGroups: [.shoulders], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Landmine Squat", category: .strength, muscleGroups: [.legs, .glutes], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Lat Pulldown (Cable)", category: .strength, muscleGroups: [.back, .biceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Lat Pulldown - Underhand (Cable)", category: .strength, muscleGroups: [.back, .biceps], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Lat Pulldown - Wide Grip (Cable)", category: .strength, muscleGroups: [.back], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Lateral Raise (Cable)", category: .strength, muscleGroups: [.shoulders], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Lateral Raise (Dumbbell)", category: .strength, muscleGroups: [.shoulders], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Laying Leg Curls", category: .strength, muscleGroups: [.legs], equipment: .machine, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Leg Extension (Machine)", category: .strength, muscleGroups: [.legs], equipment: .machine, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Leg Press", category: .strength, muscleGroups: [.legs, .glutes], equipment: .machine, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Lunge (Bodyweight)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Lunge (Dumbbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Lying Leg Curl (Machine)", category: .strength, muscleGroups: [.legs], equipment: .machine, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Overhead Press (Dumbbell)", category: .strength, muscleGroups: [.shoulders, .triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Outward Arm Swings (cable)", category: .strength, muscleGroups: [.shoulders], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Preacher Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Pull Up", category: .strength, muscleGroups: [.back, .biceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .back),
            Exercise(name: "Pullover (Dumbbell)", category: .strength, muscleGroups: [.chest, .back], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Push Up", category: .strength, muscleGroups: [.chest, .triceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .chest),
            Exercise(name: "Rear Lunge", category: .strength, muscleGroups: [.legs, .glutes], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Reverse Curl (Barbell)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Reverse Curl (Cable)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Reverse Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Reverse Fly (Dumbbell)", category: .strength, muscleGroups: [.shoulders, .back], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Reverse Grip Concentration Curl (Dumbbell)", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Reverse Incline Curl", category: .strength, muscleGroups: [.biceps, .forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .biceps),
            Exercise(name: "Romanian Deadlift (Dumbbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Russian Twist", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Seated Calf Raise (Plate Loaded)", category: .strength, muscleGroups: [.calves], equipment: .machine, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .calves),
            Exercise(name: "Seated Overhead Press (Barbell)", category: .strength, muscleGroups: [.shoulders, .triceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .shoulders),
            Exercise(name: "Seated Palms Up Wrist Curl (Dumbbell)", category: .strength, muscleGroups: [.forearms], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .forearms),
            Exercise(name: "Seated Row (Cable)", category: .strength, muscleGroups: [.back, .biceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Seated Wide-Grip Row (Cable)", category: .strength, muscleGroups: [.back], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Shrug (Barbell)", category: .strength, muscleGroups: [.back], equipment: .barbell, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Shrug (Dumbbell)", category: .strength, muscleGroups: [.back], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "Side Bend (Dumbbell)", category: .strength, muscleGroups: [.core], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Sit Up", category: .strength, muscleGroups: [.core], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .core),
            Exercise(name: "Skullcrusher (Barbell)", category: .strength, muscleGroups: [.triceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .triceps),
            Exercise(name: "Skullcrusher (Dumbbell)", category: .strength, muscleGroups: [.triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .triceps),
            Exercise(name: "Squat (Bodyweight)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Squat (Dumbbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Standing Calf Raise (Barbell)", category: .strength, muscleGroups: [.calves], equipment: .barbell, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .calves),
            Exercise(name: "Standing Calf Raise (Dumbbell)", category: .strength, muscleGroups: [.calves], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .calves),
            Exercise(name: "Standing Calf Raise (Machine)", category: .strength, muscleGroups: [.calves], equipment: .machine, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .calves),
            Exercise(name: "Stiff Leg Deadlift (Dumbbell)", category: .strength, muscleGroups: [.legs, .glutes], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .legs),
            Exercise(name: "Strict Military Press (Barbell)", category: .strength, muscleGroups: [.shoulders, .triceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .shoulders),
            Exercise(name: "Superman", category: .strength, muscleGroups: [.back], equipment: .bodyweight, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .back),
            Exercise(name: "T Bar Row", category: .strength, muscleGroups: [.back, .biceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .primary, targetMuscleGroup: .back),
            Exercise(name: "Triceps Dip", category: .strength, muscleGroups: [.triceps], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .triceps),
            Exercise(name: "Triceps Extension (Cable)", category: .strength, muscleGroups: [.triceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .triceps),
            Exercise(name: "Triceps Extension (Dumbbell)", category: .strength, muscleGroups: [.triceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .triceps),
            Exercise(name: "Triceps Pushdown (Cable - Straight Bar)", category: .strength, muscleGroups: [.triceps], equipment: .cable, description: "", instructions: [], difficulty: .beginner, exerciseType: .accessory, targetMuscleGroup: .triceps),
            Exercise(name: "Upright Row (Cable)", category: .strength, muscleGroups: [.shoulders, .biceps], equipment: .cable, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Upright Row (Dumbbell)", category: .strength, muscleGroups: [.shoulders, .biceps], equipment: .dumbbells, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Upright Row (Barbell)", category: .strength, muscleGroups: [.shoulders, .biceps], equipment: .barbell, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .shoulders),
            Exercise(name: "Wrist Roller", category: .strength, muscleGroups: [.forearms], equipment: .bodyweight, description: "", instructions: [], difficulty: .intermediate, exerciseType: .accessory, targetMuscleGroup: .forearms)
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
