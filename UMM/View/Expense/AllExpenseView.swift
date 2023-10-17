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
                
                //  Picker : 국가별
                Picker("나라 별로", selection: $expenseViewModel.selectedCountry) {
                    let allExpensesInSelectedTravel = expenseViewModel.savedExpenses
                    let countries = Array(Set(allExpensesInSelectedTravel.compactMap { $0.country })) // 중복 제거
                    Text("모든 나라").tag(0 as Int64) // Add a picker item with a tag of 0
                    
                    ForEach(countries, id: \.self) { country in
                        Text("Country: \(country)").tag(Int64(country))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: expenseViewModel.selectedCountry) { newValue in
                    print("Picker | onChange() | newValue: \(newValue)")
                    expenseViewModel.filteredExpenses = getFilteredExpenses(selectedCountry: expenseViewModel.selectedCountry)
                }
                
                Spacer()
                
                // 여행별 + 날짜별 리스트
                // 국가별로 나눠서 보여줌
                drawExpensesByCategory(expenses: expenseViewModel.filteredExpenses)
            }
        }
        .onAppear {
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            expenseViewModel.filteredExpenses = getFilteredExpenses(selectedCountry: expenseViewModel.selectedCountry)
        }
    }
    
    // 최종 배열
    private func getFilteredExpenses(selectedCountry: Int64) -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(selectedTravelID: expenseViewModel.selectedTravel?.id ?? UUID())
        print("Filtered by travel: \(filteredByTravel.count)")
        
        if selectedCountry == 0 {
            return filteredByTravel
        } else {
            return expenseViewModel.filterExpensesByCountry(expenses: filteredByTravel, country: selectedCountry)
        }
    }
    
    // 항목별로 비용 항목을 분류하여 표시
    private func drawExpensesByCategory(expenses: [Expense]) -> some View {
        let groupedExpenses = Dictionary(grouping: expenses, by: { $0.category })
        
        return ForEach(groupedExpenses.sorted(by: { $0.key < $1.key }), id: \.key) { category, expenses in
            Section(header: Text("카테고리: \(category)")) {
                ForEach(expenses, id: \.id) { expense in
                    if let payDate = expense.payDate {
                        NavigationLink(destination:
                            AllExpenseDetailView(
                                selectedTravel: $expenseViewModel.selectedTravel,
                                selectedCategory: .constant(category),
                                selectedPaymentMethod: $expenseViewModel.selectedPaymentMethod,
                                selectedCountry: $expenseViewModel.selectedCountry
                            )
                        ) {
                            VStack {
                                Text(expense.info ?? "no info")
                                Text("Category: \(expense.category)")
                                Text("Country: \(expense.country)")
                                Text("PaymentMethod: \(expense.paymentMethod)")
                                Text(payDate.description)
                            }
                            .padding()
                        }
                    }
                }
                Divider()
            }
        }
    }
    
}

#Preview {
    AllExpenseView()
}
