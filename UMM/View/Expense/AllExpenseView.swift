//
//  AllExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct AllExpenseView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var dummyRecordViewModel: DummyRecordViewModel
//    @State private var groupedExpenses = [Int64: [Expense]]()
    
    init() {
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("전체 지출")
                
                // Picker: 여행별
                Picker("현재 여행", selection: $expenseViewModel.selectedTravel) {
                    ForEach(dummyRecordViewModel.savedTravels, id: \.self) { travel in
                        Text(travel.name ?? "no name").tag(travel as Travel?) // travel의 id가 선택지로
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onReceive(expenseViewModel.$selectedTravel) { _ in
                    DispatchQueue.main.async {
                        expenseViewModel.filteredExpenses = getFilteredExpenses()
                        expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
                        print("TodayExpenseView | onReceive | done")
                    }
                }
                
                //  Picker : 국가별
                Picker("나라 별로", selection: $expenseViewModel.selectedCountry) {
                    let allExpensesInSelectedTravel = expenseViewModel.savedExpenses
                    let countries = Array(Set(allExpensesInSelectedTravel.compactMap { $0.country })).sorted { $0 < $1 } // 중복 제거
                    
                    ForEach(countries, id: \.self) { country in
                        Text("Country: \(country)").tag(Int64(country))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onReceive(expenseViewModel.$selectedCountry) { _ in
                    DispatchQueue.main.async {
                        expenseViewModel.filteredExpenses = getFilteredExpenses()
                        expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
                    }
                }

                Spacer()
                
                drawExpensesByCategory
            }
        }
        .onAppear {
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            
            expenseViewModel.filteredExpenses = getFilteredExpenses()
            expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
        }
    }
    
    // 항목별로 비용 항목을 분류하여 표시
    private var drawExpensesByCategory: some View {
        ForEach(expenseViewModel.groupedExpenses.sorted(by: { $0.key < $1.key }), id: \.key) { category, expenses in
            Section(header: Text("카테고리: \(category)")) {
                
                ForEach(expenses, id: \.id) { expense in
                    NavigationLink(destination:
                        AllExpenseDetailView(
                            selectedTravel: expenseViewModel.selectedTravel,
                            selectedCategory: category,
                            selectedCountry: expenseViewModel.selectedCountry,
                            selectedPaymentMethod: expenseViewModel.selectedPaymentMethod
                        )
                    ) {
                        VStack {
                            Text(expense.info ?? "no info")
                            Text("Category: \(expense.category)")
                            Text("Country: \(expense.country)")
                            Text("PaymentMethod: \(expense.paymentMethod)")
                        }
                        .padding()
                    }
                }
                Divider()
            }
        }
    }
    
    // 최종 배열
    private func getFilteredExpenses() -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: expenseViewModel.selectedTravel?.id ?? UUID())
        print("Filtered by travel: \(filteredByTravel.count)")
        
        let filteredByCountry = expenseViewModel.filterExpensesByCountry(expenses: filteredByTravel, country: expenseViewModel.selectedCountry)
        print("Filtered by Country: \(filteredByCountry.count)")
        
        return filteredByCountry
    }
    
}

#Preview {
    AllExpenseView()
}
