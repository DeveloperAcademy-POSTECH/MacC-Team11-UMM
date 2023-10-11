//
//  AddTravelViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import Foundation

class AddTravelViewModel: ObservableObject {

    @Published var month: Date
    @Published var startDate: Date?

    static let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    static let dateFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "M"

        return formatter
    }()

    init(month: Date) {
        self.month = month
        self.startDate = Date()
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
        if let newMonth = calendar.date(byAdding: .month, value: value, to: month) {
            self.month = newMonth
        }
    }

    func dateToDay(in date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: date)
    }
}
