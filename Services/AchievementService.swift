import Foundation

class AchievementService {

    // Brzycki formula for 1RM calculation
    func calculateOneRepMax(weight: Double, reps: Int) -> Double {
        guard reps > 0 && reps < 11 else { return weight } // Formula is most accurate for reps < 10
        return weight / (1.0278 - 0.0278 * Double(reps))
    }

    // MARK: - Achievements

    private static func allAchievements() -> [Achievement] {
        return [
            Achievement(title: "First Workout", description: "Completed your first workout.", iconName: "star.fill"),
            Achievement(title: "Workout Warrior", description: "Completed 10 workouts.", iconName: "flame.fill"),
            Achievement(title: "Consistent Lifter", description: "Worked out for 3 days in a row.", iconName: "calendar"),
            Achievement(title: "Marathon Session", description: "Completed a workout longer than 90 minutes.", iconName: "clock.fill"),
            Achievement(title: "Heavy Lifter", description: "Lifted over 5000 lbs in a single workout.", iconName: "scalemass.fill")
        ]
    }

    func checkAchievements(for workout: Workout, allWorkouts: [Workout], userProfile: inout UserProfile) {
        // Initialize achievements if they are not already
        if userProfile.achievements.isEmpty {
            userProfile.achievements = AchievementService.allAchievements()
        }

        // 1. First Workout
        if !allWorkouts.isEmpty {
            unlockAchievement(title: "First Workout", userProfile: &userProfile)
        }

        // 2. Workout Warrior (10 workouts)
        if allWorkouts.count >= 10 {
            unlockAchievement(title: "Workout Warrior", userProfile: &userProfile)
        }

        // 3. Marathon Session (> 90 minutes)
        if let duration = workout.duration, duration > 5400 { // 90 minutes * 60 seconds
            unlockAchievement(title: "Marathon Session", userProfile: &userProfile)
        }

        // 4. Heavy Lifter (> 5000 lbs)
        let totalWeight = workout.exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { $0 + (($1.weight ?? 0) * Double($1.reps)) }
        }
        if totalWeight > 5000 {
            unlockAchievement(title: "Heavy Lifter", userProfile: &userProfile)
        }

        // 5. Consistent Lifter (3 day streak)
        if hasWorkoutStreak(count: 3, allWorkouts: allWorkouts) {
            unlockAchievement(title: "Consistent Lifter", userProfile: &userProfile)
        }
    }

    private func unlockAchievement(title: String, userProfile: inout UserProfile) {
        if let index = userProfile.achievements.firstIndex(where: { $0.title == title && !$0.isEarned }) {
            userProfile.achievements[index].isEarned = true
            userProfile.achievements[index].earnedDate = Date()
        }
    }

    private func hasWorkoutStreak(count: Int, allWorkouts: [Workout]) -> Bool {
        guard allWorkouts.count >= count else { return false }

        let sortedDates = allWorkouts.map { $0.date }.sorted().reversed()

        var streak = 1
        var lastDate = sortedDates.first!

        for i in 1..<sortedDates.count {
            let currentDate = sortedDates[i]
            if let days = Calendar.current.dateComponents([.day], from: currentDate, to: lastDate).day, days == 1 {
                streak += 1
            } else if let days = Calendar.current.dateComponents([.day], from: currentDate, to: lastDate).day, days > 1 {
                streak = 1 // Reset streak
            }

            if streak >= count {
                return true
            }
            lastDate = currentDate
        }

        return false
    }

    func updatePersonalRecords(for workout: Workout, userProfile: inout UserProfile) {
        for exercise in workout.exercises {
            let exerciseName = exercise.exercise.name

            // Calculate metrics from the workout
            let maxWeight = exercise.sets.compactMap { $0.weight }.max() ?? 0
            let totalVolume = exercise.sets.reduce(0) { $0 + (($1.weight ?? 0) * Double($1.reps)) }
            let estimatedOneRepMax = exercise.sets.compactMap { aSet -> Double? in
                guard let weight = aSet.weight, aSet.reps > 0 else { return nil }
                return calculateOneRepMax(weight: weight, reps: aSet.reps)
            }.max() ?? 0

            // Update Max Weight PR
            updateRecord(exerciseName: exerciseName, recordType: .maxWeight, newValue: maxWeight, date: workout.date, userProfile: &userProfile)

            // Update Max Volume PR
            updateRecord(exerciseName: exerciseName, recordType: .maxVolume, newValue: totalVolume, date: workout.date, userProfile: &userProfile)

            // Update 1RM PR
            updateRecord(exerciseName: exerciseName, recordType: .oneRepMax, newValue: estimatedOneRepMax, date: workout.date, userProfile: &userProfile)
        }
    }

    private func updateRecord(exerciseName: String, recordType: PersonalRecord.RecordType, newValue: Double, date: Date, userProfile: inout UserProfile) {
        if let existingRecordIndex = userProfile.personalRecords.firstIndex(where: { $0.exerciseName == exerciseName && $0.recordType == recordType }) {
            // If record exists and new value is greater, update it
            if newValue > userProfile.personalRecords[existingRecordIndex].value {
                userProfile.personalRecords[existingRecordIndex].value = newValue
                userProfile.personalRecords[existingRecordIndex].date = date
            }
        } else {
            // If no record exists, create a new one
            let newRecord = PersonalRecord(exerciseName: exerciseName, recordType: recordType, value: newValue, date: date)
            userProfile.personalRecords.append(newRecord)
        }
    }
}
