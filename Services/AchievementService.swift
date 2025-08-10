import Foundation

class AchievementService {

    // Brzycki formula for 1RM calculation
    func calculateOneRepMax(weight: Double, reps: Int) -> Double {
        guard reps > 0 && reps < 11 else { return weight } // Formula is most accurate for reps < 10
        return weight / (1.0278 - 0.0278 * Double(reps))
    }

    // Recalculates all PRs and achievements from a full workout history
    func recalculateAll(from allWorkouts: [Workout], for userProfile: inout UserProfile) {
        // Reset all current PRs and achievements
        userProfile.personalRecords = []
        userProfile.achievements = AchievementService.allAchievements()

        // Sort workouts by date to process them chronologically
        let sortedWorkouts = allWorkouts.sorted { $0.date < $1.date }

        var processedWorkouts: [Workout] = []
        var totalBrokenPRs = 0

        for workout in sortedWorkouts {
            processedWorkouts.append(workout)
            // Assumes the historical workout data is in the unit set in the user's profile
            let brokenPRsInWorkout = updatePersonalRecords(for: workout, userProfile: &userProfile, unit: userProfile.weightUnit)
            totalBrokenPRs += brokenPRsInWorkout
            checkAchievements(for: workout, allWorkouts: processedWorkouts, userProfile: &userProfile, brokenPRs: totalBrokenPRs)
        }
    }

    // MARK: - Achievements

    private static func allAchievements() -> [Achievement] {
        return [
            // --- Consistency & Frequency ---
            Achievement(title: "First Workout", description: "Completed your first workout.", iconName: "star.fill"),
            Achievement(title: "Getting Started", description: "Completed 5 workouts.", iconName: "figure.walk.arrival"),
            Achievement(title: "Workout Warrior", description: "Completed 10 workouts.", iconName: "flame.fill"),
            Achievement(title: "Serious Contender", description: "Completed 25 workouts.", iconName: "figure.strengthtraining.traditional"),
            Achievement(title: "Dedicated", description: "Completed 50 workouts.", iconName: "person.fill.checkmark"),
            Achievement(title: "Centurion", description: "Completed 100 workouts.", iconName: "100.square.fill"),
            Achievement(title: "Veteran", description: "Completed 250 workouts.", iconName: "shield.fill"),
            Achievement(title: "Elite", description: "Completed 500 workouts.", iconName: "crown.fill"),

            Achievement(title: "Warming Up", description: "Worked out for 3 days in a row.", iconName: "3.circle"),
            Achievement(title: "On a Roll", description: "Worked out for 7 days in a row.", iconName: "7.circle"),
            Achievement(title: "Unstoppable", description: "Worked out for 14 days in a row.", iconName: "14.circle"),
            Achievement(title: "Legendary Streak", description: "Worked out for 30 days in a row.", iconName: "30.circle"),
            Achievement(title: "Immortal", description: "Worked out for 100 days in a row.", iconName: "infinity.circle.fill"),

            Achievement(title: "Monthly Regular", description: "Completed 10 workouts in a calendar month.", iconName: "calendar.badge.clock"),
            Achievement(title: "Monthly Warrior", description: "Completed 15 workouts in a calendar month.", iconName: "calendar.badge.plus"),
            Achievement(title: "Monthly Champion", description: "Completed 20 workouts in a calendar month.", iconName: "calendar.badge.exclamationmark"),

            Achievement(title: "Perfect Week", description: "Completed a workout every day for a full week.", iconName: "calendar.circle.fill"),
            Achievement(title: "Weekend Warrior", description: "Completed a workout on a Saturday and Sunday in the same week.", iconName: "w.square.fill"),
            Achievement(title: "Two-a-Day", description: "Completed two workouts in a single day.", iconName: "2.square.fill"),
            Achievement(title: "Loyalist", description: "You've been using the app for one year.", iconName: "1.circle.fill"),

            // --- Volume & PRs ---
            Achievement(title: "Light Lifter", description: "Lifted a total of 10,000 kg/lbs in a single workout.", iconName: "scalemass"),
            Achievement(title: "Heavy Lifter", description: "Lifted a total of 25,000 kg/lbs in a single workout.", iconName: "scalemass.fill"),
            Achievement(title: "Super Heavy Lifter", description: "Lifted a total of 50,000 kg/lbs in a single workout.", iconName: "bolt.fill"),

            Achievement(title: "PR Setter", description: "Set your first Personal Record.", iconName: "trophy"),
            Achievement(title: "Record Breaker", description: "Broke 10 of your existing Personal Records.", iconName: "trophy.fill"),
            Achievement(title: "Goal Crusher", description: "Broke 50 of your existing Personal Records.", iconName: "crown"),

            Achievement(title: "Millionaire Club", description: "Lifted a total of 1,000,000 kg/lbs over your lifetime.", iconName: "dollarsign.circle.fill"),
            Achievement(title: "Multi-Millionaire", description: "Lifted a total of 5,000,000 kg/lbs over your lifetime.", iconName: "dollarsign.square.fill"),

            // --- Duration & Time ---
            Achievement(title: "Quick Start", description: "Completed a workout in under 30 minutes.", iconName: "hare.fill"),
            Achievement(title: "Standard Session", description: "Completed a workout between 45 and 75 minutes.", iconName: "tortoise.fill"),
            Achievement(title: "Marathon Session", description: "Completed a workout longer than 90 minutes.", iconName: "clock.fill"),
            Achievement(title: "Endurance Master", description: "Your total workout time has exceeded 24 hours.", iconName: "24.circle"),
            Achievement(title: "Time Lord", description: "Your total workout time has exceeded 100 hours.", iconName: "hourglass"),

            Achievement(title: "Early Bird", description: "Completed 10 workouts before 7 AM.", iconName: "sunrise.fill"),
            Achievement(title: "Night Owl", description: "Completed 10 workouts after 9 PM.", iconName: "moon.stars.fill"),

            // --- Variety ---
            Achievement(title: "Explorer", description: "Performed 10 different exercises.", iconName: "magnifyingglass"),
            Achievement(title: "Adventurer", description: "Performed 25 different exercises.", iconName: "map.fill"),
            Achievement(title: "Pioneer", description: "Performed 50 different exercises.", iconName: "globe.americas.fill"),

            Achievement(title: "Well-Rounded", description: "Trained every major muscle group in a single week.", iconName: "figure.mind.and.body"),
            Achievement(title: "Specialist", description: "Completed 10 workouts for the same muscle group.", iconName: "scope"),

            Achievement(title: "Bodyweight Pro", description: "Completed 25 bodyweight workouts.", iconName: "figure.cooldown"),
            Achievement(title: "Dumbbell Devotee", description: "Completed 25 workouts using dumbbells.", iconName: "dumbbell.fill"),
            Achievement(title: "Barbell Boss", description: "Completed 25 workouts using a barbell.", iconName: "figure.strengthtraining.functional"),
            Achievement(title: "Machine Master", description: "Completed 25 workouts using machines.", iconName: "gearshape.2.fill"),

            // --- Special Days ---
            Achievement(title: "New Year, New Me", description: "Completed a workout on January 1st.", iconName: "party.popper.fill"),
            Achievement(title: "Holiday Hustle", description: "Completed a workout on Christmas Day (Dec 25th).", iconName: "gift.fill"),
            Achievement(title: "The Comeback", description: "Completed a workout after more than a month of inactivity.", iconName: "arrow.uturn.backward.circle.fill")
        ]
    }

    func checkAchievements(for workout: Workout, allWorkouts: [Workout], userProfile: inout UserProfile, brokenPRs: Int) {
        // Initialize achievements if they are not already
        if userProfile.achievements.isEmpty {
            userProfile.achievements = AchievementService.allAchievements()
        }

        // --- Consistency & Frequency ---
        let totalWorkouts = allWorkouts.count
        if totalWorkouts >= 1 { unlockAchievement(title: "First Workout", date: workout.date, userProfile: &userProfile) }
        if totalWorkouts >= 5 { unlockAchievement(title: "Getting Started", date: workout.date, userProfile: &userProfile) }
        if totalWorkouts >= 10 { unlockAchievement(title: "Workout Warrior", date: workout.date, userProfile: &userProfile) }
        if totalWorkouts >= 25 { unlockAchievement(title: "Serious Contender", date: workout.date, userProfile: &userProfile) }
        if totalWorkouts >= 50 { unlockAchievement(title: "Dedicated", date: workout.date, userProfile: &userProfile) }
        if totalWorkouts >= 100 { unlockAchievement(title: "Centurion", date: workout.date, userProfile: &userProfile) }
        if totalWorkouts >= 250 { unlockAchievement(title: "Veteran", date: workout.date, userProfile: &userProfile) }
        if totalWorkouts >= 500 { unlockAchievement(title: "Elite", date: workout.date, userProfile: &userProfile) }

        if hasWorkoutStreak(count: 3, allWorkouts: allWorkouts) { unlockAchievement(title: "Warming Up", date: workout.date, userProfile: &userProfile) }
        if hasWorkoutStreak(count: 7, allWorkouts: allWorkouts) { unlockAchievement(title: "On a Roll", date: workout.date, userProfile: &userProfile) }
        if hasWorkoutStreak(count: 14, allWorkouts: allWorkouts) { unlockAchievement(title: "Unstoppable", date: workout.date, userProfile: &userProfile) }
        if hasWorkoutStreak(count: 30, allWorkouts: allWorkouts) { unlockAchievement(title: "Legendary Streak", date: workout.date, userProfile: &userProfile) }
        if hasWorkoutStreak(count: 100, allWorkouts: allWorkouts) { unlockAchievement(title: "Immortal", date: workout.date, userProfile: &userProfile) }

        let calendar = Calendar.current
        let workoutsThisMonth = allWorkouts.filter { calendar.isDate($0.date, equalTo: workout.date, toGranularity: .month) }.count
        if workoutsThisMonth >= 10 { unlockAchievement(title: "Monthly Regular", date: workout.date, userProfile: &userProfile) }
        if workoutsThisMonth >= 15 { unlockAchievement(title: "Monthly Warrior", date: workout.date, userProfile: &userProfile) }
        if workoutsThisMonth >= 20 { unlockAchievement(title: "Monthly Champion", date: workout.date, userProfile: &userProfile) }

        // --- Volume & PRs ---
        let singleWorkoutVolume = workout.exercises.reduce(0) { $0 + $1.sets.reduce(0) { $0 + (($1.weight ?? 0) * Double($1.reps)) } }
        if singleWorkoutVolume >= 10000 { unlockAchievement(title: "Light Lifter", date: workout.date, userProfile: &userProfile) }
        if singleWorkoutVolume >= 25000 { unlockAchievement(title: "Heavy Lifter", date: workout.date, userProfile: &userProfile) }
        if singleWorkoutVolume >= 50000 { unlockAchievement(title: "Super Heavy Lifter", date: workout.date, userProfile: &userProfile) }

        if !userProfile.personalRecords.isEmpty { unlockAchievement(title: "PR Setter", date: workout.date, userProfile: &userProfile) }
        if brokenPRs >= 10 { unlockAchievement(title: "Record Breaker", date: workout.date, userProfile: &userProfile) }
        if brokenPRs >= 50 { unlockAchievement(title: "Goal Crusher", date: workout.date, userProfile: &userProfile) }

        let lifetimeVolume = allWorkouts.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.reduce(0) { $0 + (($1.weight ?? 0) * Double($1.reps)) } } }
        if lifetimeVolume >= 1000000 { unlockAchievement(title: "Millionaire Club", date: workout.date, userProfile: &userProfile) }
        if lifetimeVolume >= 5000000 { unlockAchievement(title: "Multi-Millionaire", date: workout.date, userProfile: &userProfile) }

        // --- Duration & Time ---
        if let duration = workout.duration {
            if duration < 1800 { unlockAchievement(title: "Quick Start", date: workout.date, userProfile: &userProfile) }
            if duration >= 2700 && duration <= 4500 { unlockAchievement(title: "Standard Session", date: workout.date, userProfile: &userProfile) }
            if duration > 5400 { unlockAchievement(title: "Marathon Session", date: workout.date, userProfile: &userProfile) }
        }

        let totalWorkoutTime = allWorkouts.compactMap { $0.duration }.reduce(0, +)
        if totalWorkoutTime > 86400 { unlockAchievement(title: "Endurance Master", date: workout.date, userProfile: &userProfile) } // 24 hours
        if totalWorkoutTime > 360000 { unlockAchievement(title: "Time Lord", date: workout.date, userProfile: &userProfile) }     // 100 hours

        let hour = calendar.component(.hour, from: workout.date)
        if hour < 7 {
            let earlyWorkouts = allWorkouts.filter { calendar.component(.hour, from: $0.date) < 7 }.count
            if earlyWorkouts >= 10 { unlockAchievement(title: "Early Bird", date: workout.date, userProfile: &userProfile) }
        }
        if hour >= 21 {
            let lateWorkouts = allWorkouts.filter { calendar.component(.hour, from: $0.date) >= 21 }.count
            if lateWorkouts >= 10 { unlockAchievement(title: "Night Owl", date: workout.date, userProfile: &userProfile) }
        }

        // --- Variety ---
        let distinctExercises = Set(allWorkouts.flatMap { $0.exercises.map { $0.exercise.name } })
        if distinctExercises.count >= 10 { unlockAchievement(title: "Explorer", date: workout.date, userProfile: &userProfile) }
        if distinctExercises.count >= 25 { unlockAchievement(title: "Adventurer", date: workout.date, userProfile: &userProfile) }
        if distinctExercises.count >= 50 { unlockAchievement(title: "Pioneer", date: workout.date, userProfile: &userProfile) }

        // --- Special Days ---
        let components = calendar.dateComponents([.day, .month], from: workout.date)
        if components.day == 1 && components.month == 1 { unlockAchievement(title: "New Year, New Me", date: workout.date, userProfile: &userProfile) }
        if components.day == 25 && components.month == 12 { unlockAchievement(title: "Holiday Hustle", date: workout.date, userProfile: &userProfile) }
    }

    private func unlockAchievement(title: String, date: Date, userProfile: inout UserProfile) {
        if let index = userProfile.achievements.firstIndex(where: { $0.title == title && !$0.isEarned }) {
            userProfile.achievements[index].isEarned = true
            userProfile.achievements[index].earnedDate = date
        }
    }

    private func hasWorkoutStreak(count: Int, allWorkouts: [Workout]) -> Bool {
        guard allWorkouts.count >= count else { return false }

        // Get unique workout days, sorted from most recent to oldest
        let calendar = Calendar.current
        let uniqueWorkoutDays = Set(allWorkouts.map { calendar.startOfDay(for: $0.date) })
        let sortedDays = Array(uniqueWorkoutDays).sorted(by: >)

        guard sortedDays.count >= count else { return false }

        var streak = 1
        // If the required streak is 1, it's always true if there's at least one workout.
        if count == 1 && !sortedDays.isEmpty {
            return true
        }

        for i in 0..<(sortedDays.count - 1) {
            let currentDay = sortedDays[i]
            let nextDay = sortedDays[i+1]

            if let daysBetween = calendar.dateComponents([.day], from: nextDay, to: currentDay).day, daysBetween == 1 {
                streak += 1
            } else {
                // Reset streak if the days are not consecutive
                streak = 1
            }

            if streak >= count {
                return true
            }
        }

        return streak >= count
    }

    func updatePersonalRecords(for workout: Workout, userProfile: inout UserProfile, unit: UserProfile.WeightUnit) -> Int {
        var brokenPRs = 0
        for exercise in workout.exercises {
            let exerciseName = exercise.exercise.name

            // Calculate metrics from the workout (these are in the user's selected unit)
            var maxWeight = exercise.sets.compactMap { $0.weight }.max() ?? 0
            var totalVolume = exercise.sets.reduce(0) { $0 + (($1.weight ?? 0) * Double($1.reps)) }
            var estimatedOneRepMax = exercise.sets.compactMap { aSet -> Double? in
                guard let weight = aSet.weight, aSet.reps > 0 else { return nil }
                return calculateOneRepMax(weight: weight, reps: aSet.reps)
            }.max() ?? 0

            // If the user's unit is pounds, convert to KG for storage
            if unit == .pounds {
                let lbsToKg = 0.453592
                maxWeight *= lbsToKg
                totalVolume *= lbsToKg
                estimatedOneRepMax *= lbsToKg
            }

            // Update Max Weight PR (now in KG)
            if updateRecord(exerciseName: exerciseName, recordType: .maxWeight, newValue: maxWeight, date: workout.date, userProfile: &userProfile) {
                brokenPRs += 1
            }

            // Update Max Volume PR (now in KG)
            if updateRecord(exerciseName: exerciseName, recordType: .maxVolume, newValue: totalVolume, date: workout.date, userProfile: &userProfile) {
                brokenPRs += 1
            }

            // Update 1RM PR (now in KG)
            if updateRecord(exerciseName: exerciseName, recordType: .oneRepMax, newValue: estimatedOneRepMax, date: workout.date, userProfile: &userProfile) {
                brokenPRs += 1
            }
        }
        return brokenPRs
    }

    private func updateRecord(exerciseName: String, recordType: PersonalRecord.RecordType, newValue: Double, date: Date, userProfile: inout UserProfile) -> Bool {
        // Do not record PRs for 0 values
        guard newValue > 0 else { return false }

        if let existingRecordIndex = userProfile.personalRecords.firstIndex(where: { $0.exerciseName == exerciseName && $0.recordType == recordType }) {
            // If record exists and new value is greater, update it
            if newValue > userProfile.personalRecords[existingRecordIndex].value {
                userProfile.personalRecords[existingRecordIndex].value = newValue
                userProfile.personalRecords[existingRecordIndex].date = date
                return true // A record was broken
            }
        } else {
            // If no record exists, create a new one
            let newRecord = PersonalRecord(exerciseName: exerciseName, recordType: recordType, value: newValue, date: date)
            userProfile.personalRecords.append(newRecord)
            return true // A new record is also considered "breaking" for achievement purposes
        }
        return false
    }
}
