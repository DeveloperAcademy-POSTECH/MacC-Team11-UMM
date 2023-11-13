//
//  AddTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct AddTravelView: View {
    
    @ObservedObject var viewModel = AddTravelViewModel(currentMonth: Date(), currentYear: Date())
    @Environment(\.dismiss) private var dismiss
    @State private var modalDate = Date()
    @State private var showStartModal = false
    @State private var showEndModal = false
    @State private var isButtonOn = false
   
    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                
                headerView
                
                Spacer()
                
                VStack {
                    
                    calendarHeader
                    calendarGridView
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.size.width-40, height: 423)
                .padding(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .inset(by: 0.5)
                        .stroke(Color.gray200, lineWidth: 1)
                        .frame(width: UIScreen.main.bounds.size.width-40, height: 423)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    if viewModel.startDate != nil {
                        NextButtonActive(title: "다음", action: {
                            isButtonOn = true
                        })
                        .ignoresSafeArea()
                    } else {
                        NextButtonUnactive(title: "다음", action: {
                            
                        })
                        .disabled(true)
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationDestination(isPresented: $isButtonOn) {
            AddMemberView(addViewModel: viewModel, participantArr: [""], startDate: $viewModel.startDate, endDate: $viewModel.endDate)
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("새로운 여행 생성")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }

    private var headerView: some View {
        
        return VStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                HStack {
                    Text("기간을 입력해주세요")
                        .font(.custom(FontsManager.Pretendard.semiBold, size: 24))
                    
                    Spacer()
                }
                .padding(.bottom, 10)
                
                HStack {
                    Text("여행의 시작일과 종료일을 설정해주세요.")
                        .font(.custom(FontsManager.Pretendard.medium, size: 16))
                        .foregroundStyle(Color.gray300)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            VStack {
                HStack {
                    HStack {
                        Text("시작일")
                            .font(.subhead1)
                        +
                        Text("*")
                            .font(.subhead1)
                            .foregroundStyle(Color.mainPink)
                    }
                    
                    Rectangle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 104, height: 1)
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [Color.mainPink, viewModel.endDate != nil ? Color.mainPink : Color.white]),
                                           startPoint: .leading, endPoint: .trailing)
                        )
                    
                    Text("종료일")
                        .font(.subhead1)
                }
                
                HStack {
                    Button {
                        self.showStartModal = true
                    } label: {
                        ZStack {
                    
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 132, height: 28, alignment: .leading)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .inset(by: 0.5)
                                        .stroke(viewModel.startDate != nil ? LinearGradient(gradient: Gradient(colors: [Color.mainPink, Color.mainOrange]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color.gray200, Color.gray200]), startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: viewModel.startDate != nil ? 2.0 : 1.0)
                                )
                            
                            HStack {
                                Text(viewModel.startDateToString(in: viewModel.startDate))
                                    .font(.custom(FontsManager.Pretendard.regular, size: 16))
                                    .foregroundStyle(Color.black)
                                    .padding(.leading, 20)
                                    .padding(.vertical, 6)
                                
                                Spacer()
                            }
                            
                        }
                    }
                    .sheet(isPresented: $showStartModal) {
                        startDatePickerModalView
                            .presentationDetents([.height(354), .height(354)])
                    }
                    
                    Spacer()
                    
                    Button {
                        self.showEndModal = true
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 132, height: 28, alignment: .leading)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .inset(by: 0.5)
                                        .stroke(viewModel.endDate != nil ? LinearGradient(gradient: Gradient(colors: [Color.mainPink, Color.mainOrange]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color.gray200, Color.gray200]), startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: viewModel.endDate != nil ? 2.0 : 1.0)
                                )
                            
                            HStack {
                                Text(viewModel.endDateToString(in: viewModel.endDate))
                                    .font(.custom(FontsManager.Pretendard.regular, size: 16))
                                    .foregroundStyle(viewModel.endDate == nil ? Color.gray300 : Color.black)
                                    .padding(.leading, 20)
                                    .padding(.vertical, 6)
                                Spacer()
                            }
                        }
                    }
                    .sheet(isPresented: $showEndModal) {
                        endDatePickerModalView
                            .presentationDetents([.height(354), .height(354)])
                    }
                }
                .padding(.horizontal, 40)
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
                    Image("calendar_left")
                }
                
                Spacer()
                
                Text(viewModel.year, formatter: AddTravelViewModel.dateYearFormatter)
                    .font(.calendar1)
                    .foregroundStyle(Color(0x333333))
                +
                Text(".")
                    .font(.calendar1)
                    .foregroundStyle(Color(0x333333))
                +
                Text(viewModel.month, formatter: AddTravelViewModel.dateFormatter)
                    .font(.calendar1)
                    .foregroundStyle(Color(0x333333))
                
                Spacer()
                
                Button {
                    viewModel.changeMonth(by: 1)
                } label: {
                    Image("calendar_right")
                }
            }
            .padding(.horizontal, 30)

            HStack {
                ForEach(koreanWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundStyle(Color.gray300)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.top, 24)
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
                        
                        CellView(day: day, viewModel: viewModel, date: date, textColor: Color.gray200)
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
                        
                        CellView(day: day, viewModel: viewModel, date: date, textColor: Color.gray200)
                            .disabled(true)
                    }
                }
            }
            .padding(.horizontal, 20)
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
        
        // 시작일과 종료일 사이
        private func isSelected(date: Date) -> Bool {
            if date > viewModel.startDate ?? Date() && viewModel.endDate != nil && viewModel.endDate! > date {
                return true
            } else {
                return false
            }
        }
        
        // 시작일과 종료일이 같을 경우
        private func isSameDate(date: Date) -> Bool {
            if let startDate = viewModel.startDate, let endDate = viewModel.endDate,
                viewModel.startDateToString(in: self.date! - 1) == viewModel.startDateToString(in: startDate) &&
                viewModel.startDateToString(in: self.date! - 1) == viewModel.startDateToString(in: endDate) {
                return true
            } else {
                return false
            }
        }
        
        private func isEndDateSelected(date: Date?) -> Bool {
            if date == nil {
                return false
            } else {
                return true
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                Button {
                    let result = viewModel.startDateEndDate(in: viewModel.startDate, endDate: viewModel.endDate, selectDate: date!-1)
                    viewModel.startDate = result[0]
                    viewModel.endDate = result[1]
                    
                    viewModel.selectDate = date! - 1
                    viewModel.isSelectedStartDate = true
                } label: {
                    Text(String(day))
                        .padding(9.81)
                        .font(.calendar2)
                        .frame(width: 50) // 45
                        .foregroundStyle(textColor)
                        .overlay {
                            if isSameDate(date: self.date!) {
                                ZStack {
                                    Circle()
                                        .frame(width: 38, height: 38)
                                        .foregroundStyle(Color.mainPink)
                                    
                                    Circle()
                                        .frame(width: 35, height: 35)
                                        .foregroundStyle(Color.white)
                                    
                                    Circle()
                                        .frame(width: 33, height: 33)
                                        .foregroundStyle(Color.mainPink)
                                    
                                    Text(String(day))
                                        .font(.calendar2)
                                        .padding(9.81)
                                        .frame(width: 45, height: 41)
                                        .foregroundStyle(Color.white)
                                }
                            } else if viewModel.startDateToString(in: viewModel.startDate ?? Date(timeIntervalSinceReferenceDate: 8)) == viewModel.startDateToString(in: self.date! - 1) {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 28, height: 33)
                                        .foregroundStyle(isEndDateSelected(date: viewModel.endDate) ? Color(0xFFCCD5) : Color.clear)
                                        .offset(x: 15)
                                    
                                    Circle()
                                        .frame(width: 33, height: 33)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white)
                                                .fill(Color.mainPink)
                                        )
                                    
                                    Text(String(day))
                                        .padding(9.81)
                                        .font(.calendar2)
                                        .frame(width: 45, height: 41)
                                        .foregroundStyle(Color.white)
                                }
                            } else if isSelected(date: self.date!) {
                                ZStack {
                                    
                                    Text(String(day))
                                        .padding(9.81)
                                        .font(.calendar2)
                                        .foregroundStyle(Color.white)
                                        .frame(width: 47) // 45
                                        .background(
                                            Rectangle()
                                                .foregroundStyle(Color(0xFFCCD5))
                                                .frame(width: 50, height: 33)
                                        )
                                        .foregroundStyle(textColor)
                                }
                            } else if viewModel.endDateToString(in: viewModel.endDate ?? Date(timeIntervalSinceReferenceDate: 8)) == viewModel.endDateToString(in: self.date! - 1) {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 28, height: 33)
                                        .foregroundStyle(Color(0xFFCCD5))
                                        .offset(x: -15)
                                    
                                    Circle()
                                        .frame(width: 33, height: 33)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white)
                                                .fill(Color.mainPink)
                                        )
                                    
                                    Text(String(day))
                                        .font(.calendar2)
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
