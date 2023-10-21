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
    @State var selectedPaymentMethod: Int64 = -1
    @State private var currencySums: [CurrencyAndSum] = []
    
    var body: some View {
        ScrollView {
            Picker("현재 결제 수단", selection: $selectedPaymentMethod) {
                ForEach(-1...1, id: \.self) { index in
                    Text("\(index)").tag(Int64(index))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedPaymentMethod) {
                expenseViewModel.filteredExpenses = getFilteredExpenses()
                currencySums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredExpenses)
            }
            
            Spacer()
            
            drawExpensesDetail
            
        }.onAppear {
            print("onAppear AllExpenseDetailView")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            
            let filteredResult = getFilteredExpenses()
            expenseViewModel.filteredExpenses = filteredResult
            currencySums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredExpenses)
        }
    }
    
    // 최종 배열을 그리는 함수입니다.
    private var drawExpensesDetail: some View {
        VStack {
            ForEach(currencySums, id: \.currency) { currencySum in
                Text("\(currencySum.currency): \(currencySum.sum)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
            }
            ForEach(expenseViewModel.filteredExpenses, id: \.id) { expense in
                VStack {
                    Text(expense.description)
                }.padding()
            }
        }
    }
    
    // 최종 배열
    func getFilteredExpenses() -> [Expense] {
        
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: selectedTravel?.id ?? UUID())
        print("Filtered by travel.count: \(filteredByTravel.count)")
        
        let filteredByCategory = expenseViewModel.filterExpensesByCategory(expenses: filteredByTravel, category: selectedCategory)
        print("Filtered by category.count: \(filteredByCategory.count)")

        let filteredByCountry = expenseViewModel.filterExpensesByCountry(expenses: filteredByCategory, country: selectedCountry)
        print("Filtered by Country.count: \(filteredByCountry.count)")
        
        if selectedPaymentMethod == -2 {
            return filteredByCountry
        } else {
            let filterByPaymentMethod = expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredByCountry, paymentMethod: selectedPaymentMethod)
            return filterByPaymentMethod
        }
    }
}

//  #Preview {
//      AllExpenesDetailView()
//  }
