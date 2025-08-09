//
//  CalendarView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedWorkout: Workout?

    private let calendar = Calendar.current
    private var months: [Date] {
        var dates: [Date] = []
        let today = Date()
        let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: today)!
        let oneYearFromNow = calendar.date(byAdding: .year, value: 1, to: today)!

        var date = twoYearsAgo
        while date <= oneYearFromNow {
            dates.append(date)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        return dates
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(months, id: \.self) { month in
                        MonthCalendarView(selectedWorkout: $selectedWorkout, month: month)
                            .id(month)
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(startOfMonth(for: Date()), anchor: .center)
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
    }

    private func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }
}

struct MonthCalendarView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var selectedWorkout: Workout?

    let month: Date
    private let calendar = Calendar.current

    var body: some View {
        VStack {
            // Month Header
            Text(month, formatter: .monthYear)
                .font(.title)
                .fontWeight(.bold)
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
        }
    }

    private func getDaysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }

        let firstDayOfMonth = monthInterval.start
        let firstDayOfWeek = calendar.component(.weekday, from: firstDayOfMonth)

        var days: [Date] = []

        for _ in 1..<firstDayOfWeek {
            days.append(Date.distantPast)
        }

        let range = calendar.range(of: .day, in: .month, for: month)!
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
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
}

extension DateFormatter {
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}
