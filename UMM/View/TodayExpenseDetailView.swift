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
    
    @State private var finalExpenses: [Expense]?
    @State private var pickerSelection = 0

    init(selectedTravel: Binding<Travel?>,
         selectedDate : Binding<Date>,
         selectedLocation : Binding<String>,
         selectedPaymentMethod : Binding<Int64>) {
        
        self._selectedTravel = selectedTravel
        self._selectedDate = selectedDate
        self._selectedLocation = selectedLocation
        self._selectedPaymentMethod = selectedPaymentMethod
        
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
        
        expenseViewModel.fetchExpense()
    }

   var body:some View{
      ScrollView {
          
          // Picker: 결제 수단별
             Picker("Payment Method", selection: $pickerSelection) {
                 ForEach(0..<4) { index in
                     Text("\(index)").tag(index)
                 }
             }
             .pickerStyle(MenuPickerStyle())
             .onChange(of: pickerSelection) { newValue in
                 print("Picker selection changed to \(newValue)")
                 selectedPaymentMethod = Int64(newValue)
                 finalExpenses = filteredExpenses()
             }

          
          Text("일별 지출")
          Spacer()
          drawExpensesDetail(expenses: finalExpenses ?? [Expense]())
      }
      .onAppear {
          self.finalExpenses = self.filteredExpenses()
      }
  }
    
    
//    // 최종 배열
//    private func filteredExpenses() -> [Expense] {
//        let filteredByTravel = expenseViewModel.filterExpensesByTravel(selectedTravelID:  selectedTravel?.id ?? UUID())
//        let filteredByDate = expenseViewModel.filterExpensesByDate(expenses: filteredByTravel, selectedDate: selectedDate)
//        let filteredByLocation = expenseViewModel.filterExpensesByLocation(expenses: filteredByDate, location:selectedLocation)
//        if selectedPaymentMethod == 0 {
//            return filteredByLocation
//        } else {
//            return expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredByLocation, paymentMethod: selectedPaymentMethod)
//        }
//    }
    
    // 최종 배열
    private func filteredExpenses() -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(selectedTravelID:  selectedTravel?.id ?? UUID())
        print("Filtered by travel: \(filteredByTravel.count)")
        
        let filteredByDate = expenseViewModel.filterExpensesByDate(expenses: filteredByTravel, selectedDate: selectedDate)
        print("Filtered by date: \(filteredByDate.count)")
        
        let filteredByLocation = expenseViewModel.filterExpensesByLocation(expenses: filteredByDate, location:selectedLocation)
        print("Filtered by location: \(filteredByLocation.count)")
        
        if selectedPaymentMethod == 0 {
            return filteredByLocation
        } else {
            return expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredByLocation, paymentMethod: selectedPaymentMethod)
        }
    }


    // 국가별로 비용 항목을 분류하여 표시하는 함수입니다.
    private func drawExpensesDetail(expenses: [Expense]) -> some View{
      ForEach(expenses, id: \.id) { expense in
          VStack{
              Text(expense.description)
          }.padding()
      }
    }
}

//#Preview {
//    TodayExpenseDetailView()
//}
