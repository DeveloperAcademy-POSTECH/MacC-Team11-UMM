//
//  AddTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct AddTravelView: View {

    @State private var date = Date()
    @State var month: Date
    static let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    var body: some View {
        VStack {
            header
            calendarGridView
        }
    }

    private var header: some View {

        VStack {
            HStack {
                Button { } label: {
                    Image(systemName: "arrow.left")
                        .font(.title)
                }
                Spacer()
                Text(dateToMonth(date: date) + "월")
                    .font(.title)
                Spacer()
                Button { } label: {
                    Image(systemName: "arrow.right")
                        .font(.title)
                }
            }
            HStack {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var calendarGridView: some View {
        let daysInMonth: Int = numberOfDays(in: month)
        let firstWeekday: Int = firstWeekdayOfMonth(in: month) - 1
        return VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(0 ..< daysInMonth + firstWeekday, id: \.self) { index in
                    if index < firstWeekday {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.clear)
                    } else {
//                        let date = getDate(for: index - firstWeekday)
                        let day = index - firstWeekday + 1
                        CellView(day: day)
                    }
                }
            }
        }
    }
    private struct CellView: View {
        var day: Int
        init(day: Int) {
            self.day = day
        }
        var body: some View {
            VStack {
                RoundedRectangle(cornerRadius: 5)
                    .opacity(0)
                    .overlay(Text(String(day)))
            }
        }
    }

    // 오늘 날짜에 해당하는 월을 가져오는 함수
    func dateToMonth(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"

        return dateFormatter.string(from: date)
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

    // 해당 월의 첫 날짜가 가지는 해당 주의 몇 번째 요일
    func firstWeekdayOfMonth(in date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = Calendar.current.date(from: components)!

        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }

    // 특정 해당 날짜 반환
    private func getDate(for day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: startOfMonth())!
    }
}

#Preview {
    AddTravelView(month: Date())
}
