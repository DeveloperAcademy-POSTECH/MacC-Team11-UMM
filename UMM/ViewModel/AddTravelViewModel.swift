//
//  AddTravelViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import Foundation

class AddTravelViewModel: ObservableObject {

    @Published var month: Date
    @Published var year: Date
    @Published var prevMonth: Date
    @Published var nextMonth: Date
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var selectDate: Date?
    @Published var isSelectedStartDate = false

    static let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    static let dateFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "MM"

        return formatter
    }()
    
    static let dateYearFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"

        return formatter
    }()

    static let dateToDayFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "d"

        return formatter
    }()
    
    static let startDateFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY. MM. dd"

        return formatter
    }()

    init(currentMonth: Date, currentYear: Date) {
        self.month = currentMonth
        self.year = currentYear
        self.prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        self.nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        self.startDate = nil
    }

    // 해당 월의 시작 날짜
    private func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        return Calendar.current.date(from: components)!
    }

    // 해당 월에 존재하는 일자 수
    func numberOfDays(in date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }

    // 이전 달의 일자 수
    func numbersOfPrevDays(in date: Date) -> Int {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        return Calendar.current.range(of: .day, in: .month, for: previousMonth!)?.count ?? 0
    }
    
    // 다음 달의 일자 수
    func numbersOfNextDays(in date: Date) -> Int {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        return Calendar.current.range(of: .day, in: .month, for: nextMonth!)?.count ?? 0
    }
    
    // 해당 달력의 줄 수에 알맞은 정수 값 반환
    func calculateGridItemCount(daysInMonth: Int, firstWeekday: Int) -> Int {
        if daysInMonth + firstWeekday >= 36 {
            return 42
        } else if daysInMonth + firstWeekday <= 28 {
            return 28
        } else {
            return 35
        }
    }

    // 해당 월의 첫 번째 날짜의 요일
    func firstWeekdayOfMonth(in date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }

    // 특정 해당 날짜 반환
    func getDate(for day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: startOfMonth())!
    }

    func changeMonth(by value: Int) {
        let calendar = Calendar.current
        
        if let newMonth = calendar.date(byAdding: .month, value: value, to: month),
            let prevMonth = calendar.date(byAdding: .month, value: value - 1, to: month),
           let nextMonth = calendar.date(byAdding: .month, value: value + 1, to: month),
           let newYearDate = calendar.date(from: calendar.dateComponents([.year], from: newMonth)) {
            self.month = newMonth
            self.prevMonth = prevMonth
            self.nextMonth = nextMonth
            self.year = newYearDate
        }
    }

    func dateToDay(in date: Date) -> String {
        return AddTravelViewModel.dateToDayFormatter.string(from: date)
    }
    
    func startDateToString(in date: Date?) -> String {
        if date == nil {
            return ""
        } else {
            return AddTravelViewModel.startDateFormatter.string(from: date!)
        }
    }
    
    func endDateToString(in date: Date?) -> String {
        if date == nil {
            return "미정"
        } else {
            return AddTravelViewModel.startDateFormatter.string(from: date!)
        }
    }
        
    // MARK: 시작일 + 종료일 선택 알고리즘
    func startDateEndDate(in startDate: Date?, endDate: Date?, selectDate: Date?) -> [Date?] {
        if startDate == nil && endDate == nil {
            return [selectDate, nil]
        } else if startDate != nil && endDate == nil && selectDate! >= startDate! {
            return [startDate, selectDate]
        } else if startDate != nil && endDate == nil && selectDate! < startDate! {
            return [selectDate, nil]
        } else if startDate != nil && endDate != nil {
            return [selectDate, nil]
        }
        return [nil, nil]
    }
}
