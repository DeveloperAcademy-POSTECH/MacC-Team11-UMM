//
//  AddTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct AddTravelView: View {
    
    @ObservedObject private var viewModel = AddTravelViewModel(currentMonth: Date())
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
            .padding(20)
            .overlay {
                RoundedRectangle(cornerRadius: 21.49123)
                    .inset(by: 0.51)
                    .stroke(Color.gray, lineWidth: 1.02)
                    .frame(width: UIScreen.main.bounds.size.width-15, height: .none)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                NavigationLink(destination: AddMemberView()) {
                    NextButtonActive(title: "다음", action: {
                        print("sfdsf")
                    })
                }
            }
            
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
                Text("시작일*")
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 95, height: 25)
                        .cornerRadius(3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.98, green: 0.22, blue: 0.36), lineWidth: 1)
                        )
                    Text(viewModel.startDateToString(in: viewModel.startDate))
                }
                
                Text("-")
                
                Text("종료일")
                
                ZStack {
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 95, height: 25)
                      .cornerRadius(3)
                      .overlay(
                        RoundedRectangle(cornerRadius: 3)
                          .inset(by: 0.5)
                          .stroke(.black, lineWidth: 1)
                      )
                    Text(viewModel.endDateToString(in: viewModel.endDate))
                }
            }
        }
    }

    private var calendarHeader: some View {
        
        let koreanWeekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
        
        return VStack(spacing: 30) {
            HStack {
                Button {
                    viewModel.changeMonth(by: -1)
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
                        .foregroundStyle(Color.gray)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var calendarGridView: some View {

        let daysInMonth: Int = viewModel.numberOfDays(in: viewModel.month)
        let firstWeekday: Int = viewModel.firstWeekdayOfMonth(in: viewModel.month) - 1
        let maxNumOfCalendar = viewModel.calculateGridItemCount(daysInMonth: daysInMonth, firstWeekday: firstWeekday)
        
        return VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(0 ..< maxNumOfCalendar, id: \.self) { index in
                    if index < firstWeekday {

                        let total = viewModel.numberOfDays(in: viewModel.prevMonth)
                        let date = viewModel.getDate(for: index - firstWeekday + 1)
                        let day = total - (firstWeekday - index - 1)
                        
                        CellView(day: day, viewModel: viewModel, date: date, textColor: Color.gray)
                            .disabled(true)
                        
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
                            .disabled(true)
                    }
                }
            }
        }
    }

    private struct CellView: View {

        private var day: Int
        private var date: Date?
        private var textColor: Color
        @ObservedObject private var viewModel: AddTravelViewModel

        init(day: Int, viewModel: AddTravelViewModel, date: Date?, textColor: Color) {
            self.day = day
            self.viewModel = viewModel
            self.date = date
            self.textColor = textColor
        }

        var body: some View {
            VStack {
                Button {
                    let result = viewModel.startDateEndDate(in: viewModel.startDate, endDate: viewModel.endDate, selectDate: date!-1)
                    viewModel.startDate = result[0]
                    viewModel.endDate = result[1]
                    
                    viewModel.selectDate = date! - 1
                    viewModel.isSelectedStartDate = true
                } label: {
                    Text(String(day))
                        .padding(9.81)
                        .frame(width: 45, height: 41)
                        .foregroundStyle(textColor)
                        .overlay {
                            if viewModel.startDateToString(in: viewModel.startDate ?? Date(timeIntervalSinceReferenceDate: 8)) == viewModel.startDateToString(in: self.date! - 1) {
                                ZStack {
                                    
                                    Circle()
                                        .stroke(Color.black)
                                        .fill(Color.mainPink)
                                    
                                    Text(String(day))
                                        .padding(9.81)
                                        .frame(width: 45, height: 41)
                                        .foregroundStyle(Color.white)
                                }
                            } else if viewModel.endDateToString(in: viewModel.endDate ?? Date(timeIntervalSinceReferenceDate: 8)) == viewModel.endDateToString(in: self.date! - 1) {
                                ZStack {
                                    
                                    Circle()
                                        .stroke(Color.black)
                                        .fill(Color.mainPink)
                                    
                                    Text(String(day))
                                        .padding(9.81)
                                        .frame(width: 45, height: 41)
                                        .foregroundStyle(Color.white)
                                }
                            }
                            
                        }
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
        }
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

// #Preview {
//     AddTravelView()
// }
