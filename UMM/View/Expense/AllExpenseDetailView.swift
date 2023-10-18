//
//  AllExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct AllExpenseDetailView: View {
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    @ObservedObject var dummyRecordViewModel = DummyRecordViewModel()
    
    var selectedTravel: Travel?
    var selectedCategory: Int64
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64
    
    var body: some View {
        ScrollView {
            Picker("현재 결제 수단", selection: $selectedPaymentMethod) {
                ForEach(0...2, id: \.self) { index in
                    Text("\(index)").tag(Int64(index))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedPaymentMethod) { newValue in
                print("Picker | onChange() | newValue: \(newValue)")
                expenseViewModel.filteredExpenses = getFilteredExpenses(selectedPaymentMethod: newValue)
            }
            
            Spacer()
            
            drawExpensesDetail
            
        }.onAppear {
            print("onAppear AllExpenseDetailView")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            expenseViewModel.filteredExpenses = getFilteredExpenses(selectedPaymentMethod: expenseViewModel.selectedPaymentMethod)
        }
    }
    
    // 최종 배열을 그리는 함수입니다.
    private var drawExpensesDetail: some View {
        ForEach(expenseViewModel.filteredExpenses, id: \.id) { expense in
            VStack {
                Text(expense.description)
            }.padding()
        }
    }
    
    // 최종 배열
    func getFilteredExpenses(selectedPaymentMethod: Int64) -> [Expense] {
        expenseViewModel.fetchExpense()
        
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: selectedTravel?.id ?? UUID())
        print("Filtered by travel.count: \(filteredByTravel.count)")
        
        let filteredByCategory = expenseViewModel.filterExpensesByCategory(expenses: filteredByTravel, category: selectedCategory)
        print("Filtered by category.count: \(filteredByCategory.count)")

        let filteredByCountry = expenseViewModel.filterExpensesByCountry(expenses: filteredByCategory, country: selectedCountry)
        print("Filtered by Country.count: \(filteredByCountry.count)")
        
        if selectedPaymentMethod == -1 {
            return filteredByCountry
        } else {
            return expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredByCountry, paymentMethod: selectedPaymentMethod)
        }
    }
}

//  #Preview {
//      AllExpenesDetailView()
//  }
