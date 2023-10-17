//
//  TodayExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI
import CoreData

struct TodayExpenseDetailView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var dummyRecordViewModel: DummyRecordViewModel
    
    @Binding private var selectedTravel: Travel?
    @Binding private var selectedDate: Date
    @Binding private var selectedLocation: String
    @Binding private var selectedPaymentMethod: Int64

    init(selectedTravel: Binding<Travel?>,
         selectedDate: Binding<Date>,
         selectedLocation: Binding<String>,
         selectedPaymentMethod: Binding<Int64>) {
        
        self._selectedTravel = selectedTravel
        self._selectedDate = selectedDate
        self._selectedLocation = selectedLocation
        self._selectedPaymentMethod = selectedPaymentMethod
        
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
        
        expenseViewModel.selectedPaymentMethod = selectedPaymentMethod.wrappedValue
    }

    var body: some View {
        ScrollView {

            Picker("현재 결제 수단", selection: $expenseViewModel.selectedPaymentMethod) {
                ForEach(0..<4, id: \.self) { index in
                    Text("\(index)").tag(Int64(index))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: expenseViewModel.selectedPaymentMethod) { newValue in
                print("Picker | onChange() | newValue: \(newValue)")
                expenseViewModel.filteredExpenses = getFilteredExpenses(selectedPaymentMethod: expenseViewModel.selectedPaymentMethod)
            }

            Text("일별 지출")
            
            Spacer()

            drawExpensesDetail(expenses: expenseViewModel.filteredExpenses)
        }
        .onAppear {
            self.expenseViewModel.fetchExpense()
            self.dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            expenseViewModel.filteredExpenses = getFilteredExpenses(selectedPaymentMethod: expenseViewModel.selectedPaymentMethod)
        }
    }
    
    // 최종 배열
    func getFilteredExpenses(selectedPaymentMethod: Int64) -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(selectedTravelID: selectedTravel?.id ?? UUID())
        print("Filtered by travel: \(filteredByTravel.count)")
        
        let filteredByDate = expenseViewModel.filterExpensesByDate(expenses: filteredByTravel, selectedDate: selectedDate)
        print("Filtered by date: \(filteredByDate.count)")
        
        let filteredByLocation = expenseViewModel.filterExpensesByLocation(expenses: filteredByDate, location: selectedLocation)
        print("Filtered by location: \(filteredByLocation.count)")
        
        if selectedPaymentMethod == 0 {
            return filteredByLocation
        } else {
            return expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredByLocation, paymentMethod: selectedPaymentMethod)
        }
    }

    // 국가별로 비용 항목을 분류하여 표시하는 함수입니다.
    private func drawExpensesDetail(expenses: [Expense]) -> some View {
      ForEach(expenses, id: \.id) { expense in
          VStack {
              Text(expense.description)
          }.padding()
      }
    }
}

//  #Preview {
//      TodayExpenseDetailView()
//  }
