//
//  AddTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct AddTravelView: View {

    @ObservedObject private var viewModel = AddTravelViewModel(month: Date())

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
                Text(viewModel.dateToMonth(date: viewModel.today) + "월")
                    .font(.title)
                Spacer()
                Button { } label: {
                    Image(systemName: "arrow.right")
                        .font(.title)
                }
            }
            HStack {
                ForEach(AddTravelViewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var calendarGridView: some View {
        let daysInMonth: Int = viewModel.numberOfDays(in: viewModel.month)
        let firstWeekday: Int = viewModel.firstWeekdayOfMonth(in: viewModel.month) - 1
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
}

#Preview {
    AddTravelView()
}
