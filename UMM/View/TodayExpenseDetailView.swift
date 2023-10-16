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
    
    @State private var finalExpenses: [Expense]?
    @State private var pickerSelection = 0
    
    init(expenseViewModel: ExpenseViewModel) {
        self.expenseViewModel = expenseViewModel
        self.dummyRecordViewModel = DummyRecordViewModel()
    }
    
    var body: some View {
        ScrollView {
            
            // Picker: 결제 수단별
            Picker("Payment Method", selection: $pickerSelection) {
                ForEach(0..<4) { index in
                    Text("\(index)").tag(index)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: pickerSelection) { newValue in
                expenseViewModel.selectedPaymentMethod = Int64(newValue)
                finalExpenses = filteredExpenses()
            }
            
            Text("일별 지출")
            Spacer()
            drawExpensesDetail(expenses: finalExpenses ?? [Expense]())
        }
        .onAppear {
            self.expenseViewModel.fetchExpense()
            self.finalExpenses = self.filteredExpenses()
            print("============")
            print("selectedTravel: \(String(describing: self.expenseViewModel.selectedTravel))")
            print("selectedDate: \(self.expenseViewModel.selectedDate)")
            print("selectedLocation: \(self.expenseViewModel.selectedLocation)")
            print("selectedPaymentMethod: \(self.expenseViewModel.selectedPaymentMethod)")
        }
    }

    // 최종 배열
    private func filteredExpenses() -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(selectedTravelID: self.expenseViewModel.selectedTravel?.id ?? UUID())
        print("Filtered by travel: \(filteredByTravel.count)")
        
        let filteredByDate = expenseViewModel.filterExpensesByDate(expenses: filteredByTravel, selectedDate: self.expenseViewModel.selectedDate)
        print("Filtered by date: \(filteredByDate.count)")
        
        let filteredByLocation = expenseViewModel.filterExpensesByLocation(expenses: filteredByDate, location: self.expenseViewModel.selectedLocation)
        print("Filtered by location: \(filteredByLocation.count)")
        
        if self.expenseViewModel.selectedPaymentMethod == 0 {
            return filteredByLocation
        } else {
            return self.expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredByLocation, paymentMethod: self.expenseViewModel.selectedPaymentMethod)
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
