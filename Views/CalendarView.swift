//
//  CalendarView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var month = Calendar.current.component(.month, from: Date())
    @State private var selectedWorkout: Workout?
    @State private var isShowingDetail = false

    private let calendar = Calendar.current

    var body: some View {
        VStack {
            // Year and Month Selector
            HStack {
                Button(action: {
                    self.month -= 1
                    if self.month < 1 {
                        self.month = 12
                        self.year -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                }

                Text("\(calendar.monthSymbols[month - 1]) \(String(year))")
                    .font(.title)
                    .fontWeight(.bold)

                Button(action: {
                    self.month += 1
                    if self.month > 12 {
                        self.month = 1
                        self.year += 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            // Days of the week
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    Button(action: {
                        if let workout = workoutManager.workoutHistory.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                            self.selectedWorkout = workout
                        }
                    }) {
                        Text(getDayOfMonth(date: date))
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                ZStack {
                                    if workoutManager.workoutHistory.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                                        Circle()
                                            .stroke(Color.accentColor, lineWidth: 2)
                                    } else {
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                }
                            )
                            .opacity(date < Date.distantPast ? 0 : 1)
                    }
                }
            }
            .padding()
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
    }

    private func getDaysInMonth() -> [Date] {
        var components = DateComponents()
        components.year = year
        components.month = month
        let firstOfMonth = calendar.date(from: components)!

        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let firstDayOfWeek = calendar.component(.weekday, from: firstOfMonth)

        var days: [Date] = []

        for _ in 1..<firstDayOfWeek {
            days.append(Date.distantPast)
        }

        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
            days.append(date)
        }

        return days
    }

    private func getDayOfMonth(date: Date) -> String {
        if date == Date.distantPast {
            return ""
        }
        let components = calendar.dateComponents([.day], from: date)
        return String(components.day!)
    }

    private func backgroundColor(for date: Date) -> Color {
        if date == Date.distantPast {
            return .clear
        }
        if workoutManager.workoutHistory.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return .accentColor
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}
