//
//  AllExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct AllExpenseDetailView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var dummyRecordViewModel: DummyRecordViewModel
    
    @Binding private var selectedTravel: Travel?
    @Binding private var selectedCategory: Int64
    @Binding private var selectedPaymentMethod: Int64
    @Binding private var selectedCountry: Int64
    
    init(
        selectedTravel: Binding<Travel?>,
        selectedCategory: Binding<Int64>,
        selectedPaymentMethod: Binding<Int64>,
        selectedCountry: Binding<Int64>
    ) {
        self._selectedTravel = selectedTravel
        self._selectedCategory = selectedCategory
        self._selectedPaymentMethod = selectedPaymentMethod
        self._selectedCountry = selectedCountry
        
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
        
        expenseViewModel.selectedPaymentMethod = selectedPaymentMethod.wrappedValue
    }
    
    var body: some View {
        ScrollView {
            Picker("현재 결제 수단", selection: $expenseViewModel.selectedPaymentMethod) {
                ForEach(0...2, id: \.self) { index in
                    Text("\(index)").tag(Int64(index))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: expenseViewModel.selectedPaymentMethod) { newValue in
                print("Picker | onChange() | newValue: \(newValue)")
                expenseViewModel.filteredExpenses = getFilteredExpenses(selectedPaymentMethod: newValue)
            }
            
            Spacer()
            
            drawExpensesDetail(expenses: expenseViewModel.filteredExpenses)
            
        }.onAppear {
            print("onAppear AllExpenseDetailView")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            expenseViewModel.filteredExpenses = getFilteredExpenses(selectedPaymentMethod: expenseViewModel.selectedPaymentMethod)
            print("expenseViewModel.filteredExpenses.count: \(expenseViewModel.filteredExpenses.count)")
        }
    }
    
    // 최종 배열
    func getFilteredExpenses(selectedPaymentMethod: Int64) -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(selectedTravelID: selectedTravel?.id ?? UUID())
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
    
    // 최종 배열을 그리는 함수입니다.
    private func drawExpensesDetail(expenses: [Expense]) -> some View {
        ForEach(expenses, id: \.id){ expense in
            VStack {
                Text(expense.description)
            }.padding()
        }
    }
}

//  #Preview {
//      AllExpenesDetailView()
//  }
