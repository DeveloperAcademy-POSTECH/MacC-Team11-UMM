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
    @State private var modalDate = Date()
    @State private var showStartModal = false
    @State private var showEndModal = false

    var body: some View {
        VStack {
            
            Spacer()
            
            headerView
            
            Spacer()
            
            VStack {
                Spacer()
                
                calendarHeader
                calendarGridView
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.size.width-30, height: 413)
            .padding(20)
            .overlay {
                RoundedRectangle(cornerRadius: 21.49123)
                    .inset(by: 0.51)
                    .stroke(Color.gray200, lineWidth: 1.02)
                    .frame(width: UIScreen.main.bounds.size.width-30, height: 413)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                if viewModel.startDate != nil {
                    NavigationLink(destination: AddMemberView()) {
                        NextButtonActive(title: "다음", action: {
                            
                        })
                        .disabled(true)
                    }
                } else {
                    NextButtonUnactive(title: "다음", action: {
                        
                    })
                    .disabled(true)
                }
            }
        }
        .navigationTitle("새로운 여행 생성")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }

    private var headerView: some View {
        
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Spacer()
                
                Text("기간을 입력해주세요")
                    .font(.custom(FontsManager.Pretendard.semiBold, size: 24))
                
                Spacer()
                
                Text("여행의 시작일과 종료일을 설정해주세요.")
                    .font(.custom(FontsManager.Pretendard.medium, size: 16))
                    .foregroundStyle(Color.gray300)
                
                Spacer()
            }
            
            HStack {
                Text("시작일*")
                
                Button {
                    self.showStartModal = true
                } label: {
                    ZStack {
                        Text(viewModel.startDateToString(in: viewModel.startDate))
                            .font(.custom(FontsManager.Pretendard.regular, size: 14))
                            .foregroundStyle(Color(0x6C6C6C))
                        
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 95, height: 25)
                            .cornerRadius(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .inset(by: 0.5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        
                    }
                }
                .sheet(isPresented: $showStartModal) {
                    startDatePickerModalView
                        .presentationDetents([.height(354), .height(354)])
                }
                
                Text("-")
                
                Text("종료일")
                
                Button {
                    self.showEndModal = true
                } label: {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 95, height: 25)
                            .cornerRadius(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .inset(by: 0.5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        Text(viewModel.endDateToString(in: viewModel.endDate))
                            .font(.custom(FontsManager.Pretendard.regular, size: 14))
                            .foregroundStyle(Color(0x6C6C6C))
                    }
                }
                .sheet(isPresented: $showEndModal) {
                    endDatePickerModalView
                        .presentationDetents([.height(354), .height(354)])
                }
            }
            
            Spacer()
        }
    }

    private var startDatePickerModalView: some View {
        VStack {
            DatePicker("", selection: $modalDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle()).labelsHidden()
           
            LargeButtonActive(title: "확인", action: {
                showStartModal = false
                viewModel.startDate = modalDate
            })
        }
        .onAppear {
            modalDate = viewModel.startDate ?? Date()
        }
    }
    
    private var endDatePickerModalView: some View {
        VStack {
            DatePicker("", selection: $modalDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle()).labelsHidden()
           
            LargeButtonActive(title: "확인", action: {
                showEndModal = false
                viewModel.endDate = modalDate
            })
        }
        .onAppear {
            modalDate = viewModel.endDate ?? Date()
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
                
                Text(viewModel.year, formatter: AddTravelViewModel.dateYearFormatter)
                    .font(.custom(FontsManager.Pretendard.medium, size: 20.47))
                    .foregroundStyle(Color(0x333333))
                +
                Text(".")
                    .font(.custom(FontsManager.Pretendard.medium, size: 20.47))
                    .foregroundStyle(Color(0x333333))
                +
                Text(viewModel.month, formatter: AddTravelViewModel.dateFormatter)
                    .font(.custom(FontsManager.Pretendard.medium, size: 20.47))
                    .foregroundStyle(Color(0x333333))
                
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
