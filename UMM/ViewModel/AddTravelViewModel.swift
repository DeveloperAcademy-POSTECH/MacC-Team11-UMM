//
//  AddTravelViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import Foundation

class AddTravelViewModel: ObservableObject {

    @Published var today = Date()
    @Published var month: Date

    static let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    init(month: Date) {
        self.month = month
    }

    // 오늘 날짜에 해당하는 월을 가져오는 함수
    func dateToMonth(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"

        return dateFormatter.string(from: today)
    }

    // 해당 월의 시작 날짜
    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        return Calendar.current.date(from: components)!
    }

    // 해당 월에 존재하는 일자 수
    func numberOfDays(in date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }

    // 해당 월의 첫 번쩨 날짜의 요일
    func firstWeekdayOfMonth(in date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = Calendar.current.date(from: components)!

        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }

    // 특정 해당 날짜 반환
    private func getDate(for day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: startOfMonth())!
    } // -> 변수 today로 될듯
}
