//
//  WorkoutScience.swift
//  Strong-er
//
//  Created by Jules on 8/11/25.
//

import Foundation

struct WorkoutScience {

    /// Calculates the estimated 1-Rep Max (e1RM) using the Epley formula.
    /// - Parameters:
    ///   - weight: The weight lifted.
    ///   - reps: The number of repetitions performed.
    /// - Returns: The estimated 1-Rep Max.
    static func calculateE1RM(weight: Double, reps: Int) -> Double {
        // The Epley formula is most accurate for reps between 1 and 12.
        guard reps > 0 else { return weight }
        if reps == 1 { return weight }

        let effectiveReps = Double(min(reps, 12))
        return weight * (1.0 + (effectiveReps / 30.0))
    }

    /// Defines the training parameters for a given fitness goal.
    struct GoalParameters {
        let sets: Int
        let repRange: ClosedRange<Int>
        let intensityRange: ClosedRange<Double> // Percentage of e1RM
    }

    // Defines the parameters for different fitness goals based on the research paper.
    static let strengthParams = GoalParameters(sets: 4, repRange: 4...6, intensityRange: 0.85...0.95)
    static let hypertrophyParams = GoalParameters(sets: 3, repRange: 8...12, intensityRange: 0.67...0.85)
    static let enduranceParams = GoalParameters(sets: 2, repRange: 15...20, intensityRange: 0.50...0.67)

    /// Retrieves the appropriate training parameters for a given fitness goal.
    ///
    /// For goals not directly related to strength/hypertrophy/endurance (like Weight Loss),
    /// it defaults to hypertrophy parameters, which are effective for preserving muscle and boosting metabolism.
    static func getParameters(for goal: UserProfile.FitnessGoal) -> GoalParameters {
        switch goal {
        case .strength:
            return strengthParams
        case .muscleGain:
            return hypertrophyParams
        case .endurance:
            return enduranceParams
        case .weightLoss, .flexibility, .general:
            return hypertrophyParams
        }
    }

    /// The factor by which to increase weight for progressive overload.
    static let overloadFactor: Double = 1.025 // 2.5%
}
