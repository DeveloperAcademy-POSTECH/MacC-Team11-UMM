//
//  TodayExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI
import CoreData

struct TodayExpenseDetailView: View {
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    @ObservedObject var dummyRecordViewModel = DummyRecordViewModel()
    
    var selectedTravel: Travel?
    var selectedDate: Date
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64 = -1
    var currencySums : [CurrencySum]

    var body: some View {
        ScrollView {
            Picker("현재 결제 수단", selection: $selectedPaymentMethod) {
                ForEach(-1...1, id: \.self) { index in
                    Text("\(index)").tag(Int64(index))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedPaymentMethod) { _ in
                expenseViewModel.filteredExpenses = getFilteredExpenses()
            }
            
            Spacer()

            drawExpensesDetail
        }
        .onAppear {
            print("onAppear TodayExpenseDetailView")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            expenseViewModel.filteredExpenses = getFilteredExpenses()
        }
    }
    
    // 국가별로 비용 항목을 분류하여 표시하는 함수입니다.
    private var drawExpensesDetail: some View {
        VStack {
            ForEach(expenseViewModel.filteredExpenses, id: \.id) { expense in
                VStack {
                    Text(expense.description)
                }.padding()
            }
            
            ForEach(currencySums , id:\.currency){ currencysum in
                Text("\(currencysum.currency): \(currencysum.sum)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom , 2)
            }
        }
    }
    
    // 최종 배열
    private func getFilteredExpenses() -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: selectedTravel?.id ?? UUID())
        print("Filtered by travel: \(filteredByTravel.count)")
        
        let filteredByDate = expenseViewModel.filterExpensesByDate(expenses: filteredByTravel, selectedDate: selectedDate)
        print("Filtered by date: \(filteredByDate.count)")
        
        let filteredByCountry = expenseViewModel.filterExpensesByCountry(expenses: filteredByDate, country: selectedCountry)
        print("Filtered by Country: \(filteredByCountry.count)")
        
        if selectedPaymentMethod == -2 {
            return filteredByCountry
        } else {
            let filterByPaymentMethod = expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredByCountry, paymentMethod: selectedPaymentMethod)
            return filterByPaymentMethod
        }        
    }
}
//  #Preview {
//      TodayExpenseDetailView()
//  }
