//
//  TestView.swift
//  UMM
//
//  Created by 김태현 on 10/20/23.
//

import SwiftUI

struct CustomDatePicker: View {
    @EnvironmentObject var mainVM: MainViewModel
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @Binding var selectedDate: Date {
        didSet {
            print("CustomDatePicker | selectedDate: \(selectedDate)")
            print("CustomDatePicker | startDateOfTravel: \(startDateOfTravel)")
        }
    }
    var pickerId: String
    let startDateOfTravel: Date
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        let endDateOfTravel = expenseViewModel.datePickerRange().upperBound
        
        HStack(spacing: 0) {
            // selectedDate == startDateOfTravel이면 inActiveLeft
            // 나머지 경우에는 activeLeft
            if Calendar.current.isDate(selectedDate, equalTo: startDateOfTravel, toGranularity: .day) {
                Button(action: {}, label: {
                    Image("inActivatedLeft")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                })
            } else {
                Button(action: {
                    selectedDate = selectedDate.addingTimeInterval(-86400)
                }, label: {
                    Image("activatedLeft")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                })
            }

            ZStack {
                Button {
                    expenseViewModel.triggerDatePickerPopover(pickerId: pickerId)
                } label: {
                    Text("\(expenseViewModel.selectedDate, formatter: dateFormatterWithDay)")
                        .foregroundStyle(.black)
                }
                
                // 안 보이게 하고 Button으로 호출
                DatePicker("", selection: $expenseViewModel.selectedDate,
                           in: expenseViewModel.datePickerRange(),
                           displayedComponents: [.date])
                    .labelsHidden()
                    .accessibilityIdentifier(pickerId)
                    .onReceive(expenseViewModel.$selectedDate) { _ in
                        DispatchQueue.main.async {
                            expenseViewModel.filteredTodayExpenses = expenseViewModel.getFilteredTodayExpenses()
                            expenseViewModel.groupedTodayExpenses = Dictionary(grouping: expenseViewModel.filteredTodayExpenses, by: { $0.country })
                        }
                    }
                    .colorInvert()
                    .colorMultiply(Color.clear)
            }
            if Calendar.current.isDate(selectedDate, equalTo: endDateOfTravel, toGranularity: .day) {
                Button(action: {}, label: {
                    Image("inActivatedRight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                })
            } else {
                Button(action: {
                    selectedDate = selectedDate.addingTimeInterval(86400)
                }, label: {
                    Image("activatedRight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)       
                })
            }
        }
    }
}

//  #Preview {
//      CustomDatePicker()
//  }
