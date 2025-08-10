//
//  MotivationalMessageService.swift
//  Strong-er
//
//  Created by Jules on 8/10/25.
//

import Foundation

class MotivationalMessageService {
    private let messages = [
        "The only bad workout is the one that didn't happen.",
        "Believe you can and you're halfway there.",
        "Success isn't always about greatness. It's about consistency.",
        "The pain you feel today will be the strength you feel tomorrow.",
        "You are stronger than you think."
    ]

    private let lastMessageDateKey = "lastMotivationalMessageDate"
    private let lastMessageIndexKey = "lastMotivationalMessageIndex"

    func getDailyMessage() -> String {
        let userDefaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())

        if let lastMessageDate = userDefaults.object(forKey: lastMessageDateKey) as? Date,
           let lastMessageIndex = userDefaults.object(forKey: lastMessageIndexKey) as? Int,
           Calendar.current.isDate(lastMessageDate, inSameDayAs: today) {
            return messages[lastMessageIndex]
        }

        let lastMessageIndex = userDefaults.integer(forKey: lastMessageIndexKey)
        let newMessageIndex = (lastMessageIndex + 1) % messages.count

        userDefaults.set(today, forKey: lastMessageDateKey)
        userDefaults.set(newMessageIndex, forKey: lastMessageIndexKey)

        return messages[newMessageIndex]
    }
}
