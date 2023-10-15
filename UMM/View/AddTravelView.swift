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

            Spacer()

            headerView

            Spacer()

            VStack {
                calendarHeader
                calendarGridView
            }

            Spacer()
            
            nextButton
            
            Spacer()
        }
        .navigationTitle("새로운 여행 생성")
    }

    private var headerView: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text("기간을 입력해주세요")
                .font(.title)
                .fontWeight(.bold)

            Text("여행의 시작일과 종료일을 설정해주세요.")

            HStack {
                Text("시작일")
                Text(viewModel.startDateToString(in: viewModel.startDate ?? Date()))
            }
        }
    }

    private var calendarHeader: some View {
        
        let koreanWeekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
        
        return VStack(spacing: 30) {
            HStack {
                Button {
                    viewModel.changeMonth(by: -1)
                    print(Date())
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundStyle(Color.black)
                }

                Spacer()

                Text(viewModel.month, formatter: AddTravelViewModel.dateFormatter)
                    .font(.title)
                + Text("월")
                    .font(.title)

                Spacer()

                Button {
                    viewModel.changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .padding(1.0)
                        .font(.title)
                        .foregroundStyle(Color.black)
                }
            }
            .padding(.horizontal, 20)

            HStack {
                ForEach(koreanWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var calendarGridView: some View {

        let daysInMonth: Int = viewModel.numberOfDays(in: viewModel.month)
        let firstWeekday: Int = viewModel.firstWeekdayOfMonth(in: viewModel.month) - 1
//        @State var opacityRate: Double = 0.0

        return VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(0 ..< 35, id: \.self) { index in
                    if index < firstWeekday {

                        let total = viewModel.numbersOfPrevDays(in: Date())
                        let cnt = firstWeekday
                        let date = viewModel.getDate(for: index - firstWeekday + 1)
                        let day = total - cnt + index + 2
                        
                        CellView(day: day, viewModel: viewModel, date: date)
                        
                    } else if (index >= firstWeekday) && (index < daysInMonth + firstWeekday) {
                        
                        let date = viewModel.getDate(for: index - firstWeekday + 1)
                        let day = index - firstWeekday + 1
                        CellView(day: day, viewModel: viewModel, date: date)
                        
                    } else {
                        
                        let maxNum = 35
                        let tmp = maxNum - index
                        let totalMonth = viewModel.numberOfDays(in: Date())
                        let date = viewModel.getDate(for: index - firstWeekday + 1)
                        let day = maxNum - totalMonth - tmp + 1
                        
                        CellView(day: day, viewModel: viewModel, date: date)
                    }
                }
            }
        }
    }

    private struct CellView: View {

        private var day: Int
        private var date: Date?
//        @State private var opacityRate: Double
        @ObservedObject private var viewModel: AddTravelViewModel

        init(day: Int, viewModel: AddTravelViewModel, date: Date?) {
            self.day = day
            self.viewModel = viewModel
            self.date = date
//            self._opacityRate = State(initialValue: 0.0)
        }

        var body: some View {
            VStack {
                Button {
                    viewModel.startDate = date! - 1
                    viewModel.isSelectedStartDate = true
//                    self.opacityRate = 0.5
                    
                } label: {
                    Circle()
                        .opacity(0.0)
                        .overlay(Text(String(day)))
                        .foregroundStyle(Color.black)
                }
            }
        }
    }
    
    var nextButton: some View {
        NavigationLink(destination: AddMemberView()) {
            ZStack {
                Rectangle()
                    .frame(width: 134, height: 45)
                    .foregroundStyle(viewModel.isSelectedStartDate ? Color.black : Color.gray)
                    .cornerRadius(16)
                
                Text("다음")
                    .foregroundStyle(Color.white)
            }
                
        }.disabled(!viewModel.isSelectedStartDate)
    }
}

#Preview {
    AddTravelView()
}
