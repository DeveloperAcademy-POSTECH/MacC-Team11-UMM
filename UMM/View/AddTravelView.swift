//
//  AddTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct AddTravelView: View {
    
    @ObservedObject private var viewModel = AddTravelViewModel(month: Date(), prevMonth: Date(), nextMonth: Date())
    @Environment(\.dismiss) private var dismiss

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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
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
                    print(viewModel.prevMonth)
                    print(viewModel.month)
                    print(viewModel.nextMonth)
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
                    print(viewModel.prevMonth)
                    print(viewModel.month)
                    print(viewModel.nextMonth)
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
        
        let maxNumOfCalendar = viewModel.calculateGridItemCount(daysInMonth: daysInMonth, firstWeekday: firstWeekday)
        
        return VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(0 ..< maxNumOfCalendar, id: \.self) { index in
                    if index < firstWeekday {

                        let total = viewModel.numberOfDays(in: viewModel.prevMonth)
                        let date = viewModel.getDate(for: index - firstWeekday + 1)
                        let day = total - (firstWeekday - index - 1)
                        
                        CellView(day: day, viewModel: viewModel, date: date, textColor: Color.gray)
                        
                    } else if (index >= firstWeekday) && (index < daysInMonth + firstWeekday) {
                        
                        let date = viewModel.getDate(for: index - firstWeekday + 1)
                        let day = index - firstWeekday + 1
                        
                        CellView(day: day, viewModel: viewModel, date: date, textColor: Color.black)
                        
                    } else {
                        
                        let maxNum = maxNumOfCalendar
                        let tmp = maxNum - index
                        let date = viewModel.getDate(for: index - firstWeekday + 1)
                        let day = maxNum - (daysInMonth + firstWeekday) - tmp + 1
                        
                        CellView(day: day, viewModel: viewModel, date: date, textColor: Color.gray)
                    }
                }
            }
        }
    }

    private struct CellView: View {

        private var day: Int
        private var date: Date?
//        @State private var opacityRate: Double
        private var textColor: Color
        @ObservedObject private var viewModel: AddTravelViewModel

        init(day: Int, viewModel: AddTravelViewModel, date: Date?, textColor: Color) {
            self.day = day
            self.viewModel = viewModel
            self.date = date
//            self._opacityRate = State(initialValue: 0.0)
            self.textColor = textColor
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
                        .foregroundStyle(textColor)
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
    
    var backButton: some View {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundColor(Color.black)
            }
        }
}

#Preview {
    AddTravelView()
}
